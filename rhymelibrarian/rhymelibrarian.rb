# encoding: UTF-8
%w{ chatterbot ./wordnikparty sequel ./config set}.each {|lib| require lib}

# TODO
# - Remove sentences of length greater than 126 from the table.
# - Save the id of the replied to tweet to a file.
# - When fetching timeline search using id ^ as the since_id 
# - Save the ids of the possible sentences.
# - If a sentence is used set tweeted column to true.
# - If no sentences are found look again but allow tweeted to be true.

bot = Chatterbot::Bot.new

timeline = bot.client.user_timeline('redlibrarian', :exclude_replies => true, :include_rts => false)

DB = Sequel.connect("mysql2://#{DB_USER}:#{DB_PASSWORD}@localhost/stungeye")
wordnik = WordnikParty.new(WORDNIK_KEY)

timeline.each do |tweet|
  tweet_text = tweet.text.gsub(/[#\@]\w+\b/,'').gsub(/\W+$/,'')
  last_word = tweet_text.split(' ').last.downcase
  possible_sentences = Set.new
  rhymes = wordnik.rhymes_with(last_word, 100)
  rhymes.each do |rhyme|
    sentences = DB[:rhymesentences].where("lastword LIKE ?", "%"+rhyme).where(:tweeted => false).all
    sentences.each {|sentence| possible_sentences << sentence[:words] }
  end
  puts
  puts tweet_text
  possible_sentences.each do |sentence|
    puts "\t" + sentence
  end
end