# encoding: UTF-8
%w{ chatterbot ./wordnikparty sequel ./config set}.each {|lib| require lib}

# TODO
# - Save the id of the replied to tweet to a file.
# - When fetching timeline search using id ^ as the since_id 

RHYME_PARTNER = 'stungeye'
MAX_TWEET_LENGTH = 140 - (RHYME_PARTNER.size + 1)
ID_FILE = 'last_id.txt'

bot = Chatterbot::Bot.new

DB = Sequel.connect("mysql2://#{DB_USER}:#{DB_PASSWORD}@localhost/stungeye")

def find_sentences(last_words, tweeted)
  possible_sentences = Set.new
  last_words.each do |last_word|
    sentences = DB[:rhymesentences].where("lastword = ?", last_word).where(:tweeted => tweeted).where("length < #{MAX_TWEET_LENGTH}").all
    sentences.each {|sentence| possible_sentences << { :words => sentence[:words], :id => sentence[:id] } }
  end
  possible_sentences
end

def fetch_id
  id = nil
  if File::exists?( "last_id.txt" )
    File.open("last_id.txt", "r") do |file|
      id = file.readline.to_i
    end
  end
  id
end

def save_id(id)
  File.open(ID_FILE, "w") do |file|
    file.write(id.to_s)
  end
end

wordnik = WordnikParty.new(WORDNIK_KEY)

largest_know_tweet_id = fetch_id

timeline_options = {:exclude_replies => true, :include_rts => false}
timeline_options[:since_id] = largest_know_tweet_id  if largest_know_tweet_id
tweet_ids = []
tweet_ids << largest_know_tweet_id  if largest_know_tweet_id

timeline = bot.client.user_timeline(RHYME_PARTNER, timeline_options)

timeline.each do |tweet|
  tweet_ids << tweet.id
  tweet_text = tweet.text.gsub(/[#\@]\w+\b/,'').gsub(/\W+$/,'')
  last_word = tweet_text.split(' ').last.downcase
  next  if last_word.include?('http')
  
  rhymes = wordnik.rhymes_with(last_word, 100)
  possible_sentences = find_sentences(rhymes, false)
  possible_sentences = find_sentences(rhymes, true)  if possible_sentences.size.zero?
  next  if possible_sentences.size.zero?
  
  selected_sentence = possible_sentences.to_a.shuffle.first
  DB[:rhymesentences].where(:id => selected_sentence[:id]).update(:tweeted => true)
  bot.tweet selected_sentence[:words]
end

save_id(tweet_ids.max)  unless tweet_ids.size.zero?