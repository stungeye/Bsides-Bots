# encoding: UTF-8
%w{ ./wordnikparty sequel ./config set}.each {|lib| require lib}

sam_tweet = [
  "I think my sysadmin has most experience with CFEngine, so that's fine with me if all are good tools.",
  "Not sure yet - not really my area, but I need to be able to discuss with sysadmin. I'll keep reading/researching. Thanks!",
  "Sent you a ChucK composition - listen on headphones!",
  "Discussion of using resources to create MARC records for web archives makes me a sad, sad panda.",
  'Ha! "Show me a dev who\'s not #causing an outage, and I\'ll show you a dev who\'s on vacation." #devops',
  "Also, am I right in thinking that Rails production environments should prefer gems over system packages, when both are available?",
  "Anybody have thoughts on CFEngine? Vs Puppet or Chef? / @stungeye",
  "Huh. So with nary an objection, we're going with DevOps for our Discovery project....",
  "So far, puppet's taking it for me."
  
]

if File::exists?( "last_id.txt" )
  File.open("last_id.txt", "r") do |file|
    puts file.readline
  end
else
  puts "No id set."
end

File.open("last_id.txt", "w") do |file|
  file.write(rand(100000).to_s)
end

DB = Sequel.connect("mysql2://#{DB_USER}:#{DB_PASSWORD}@localhost/stungeye")
wordnik = WordnikParty.new(WORDNIK_KEY)

sam_tweet.each do |tweet|
  tweet = tweet.gsub(/[#\@]\w+\b/,'')
  tweet = tweet.gsub(/\W+$/,'')
  last_word = tweet.split(' ').last.downcase
  puts last_word
  possible_sentences = Set.new
  rhymes = wordnik.rhymes_with(last_word, 100)
  rhymes.each do |rhyme|
    sentences = DB[:rhymesentences].where("lastword = ?", rhyme).all
    sentences.each {|sentence| possible_sentences << [sentence[:id], sentence[:words]] }
  end
  puts
  puts tweet
  puts "\t" + possible_sentences.to_a.shuffle.first[1]  unless possible_sentences.size.zero?
  puts "\t No Rhyme Found."  if possible_sentences.size.zero?  
  #possible_sentences.each do |sentence|
  #  puts "\t" + sentence
  #end
end


#rhymesentences = DB[:rhymesentences].all
#
#rhymesentences.each do |sentence|
#  lastword =  sentence[:words].split(' ').last.gsub(/\W+/, '').downcase
#  DB[:rhymesentences].where(:id => sentence[:id]).update(:lastword => lastword)
#end

