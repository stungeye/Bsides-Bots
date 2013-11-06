# encoding: UTF-8

def fixit(sentence)
  while ['"',"'","-",")",","].include?(sentence[0])
    sentence = sentence[1,sentence.size-1]
    sentence.strip!
  end
  sentence.capitalize!
  if sentence.count('"').odd?
    sentence += '"'
  end
  if sentence.count("(") > sentence.count(")")
    sentence += ")"
  end
  sentence
end

# Read the entire file into a single string, ensure that line-ending
# are padding with extra spaces.

corpus = ''
open('communist_manifesto.txt', 'r:UTF-8') do |file|
  file.each do |line|
    corpus += line.strip + ' '
  end
end

puts "Corpus length: #{corpus.length/140}"

accepted = []
rejected = []

# Split the corpus on periods, so we may get multiple sentences per split
# depending on the punctuation. 
# Accepted senteces will be tweet sized, but longer than 15 chars. 

corpus.split('.').map{ |s| s.strip }.select{ |s| s.size > 0 }.each do |sentence|
  sentence += '.'
  #sentence = fixit(sentence)
  accepted << sentence  if sentence.size > 15 && sentence.size <= 140 
  rejected << sentence  if sentence.size > 140
end

puts "Accepted: #{accepted.size}"
puts "Rejected: #{rejected.size}"

# Of the rejected setences split again on question marks. See if any of these
# newly split setences are tweet-sized and reject the rest.

more_rejects = []
rejected.each do |reject|
  reject.split('?').map{|s| s.strip }.select{ |s| s.size > 0 }.each do |sentence|
    sentence += '?'  unless sentence[-1] == '.'
    sentence = fixit(sentence)
    accepted << sentence  if sentence.size > 15 && sentence.size <= 140
    more_rejects << sentence  if sentence.size > 140
  end
end

rejected = more_rejects
puts "here"
#DB = Sequel.connect("mysql2://#{DB_USER}:#{DB_PASSWORD}@localhost/stungeye")
#sentences = DB[:sentences]

#open('sentences.txt', 'w:UTF-8') do |file|
  #accepted.each do |sentence|
    #file.puts "#{sentence} (#{sentence.size})"
  #end
#end

puts "ACCEPTED:\n"
 accepted.each do |sentence|
   puts sentence
   #sentences.insert( :words => sentence, :length => sentence.size )
 end

puts "\nREJECTED:\n"
 rejected.each do |sentence|
   puts sentence
   #sentences.insert( :words => sentence, :length => sentence.size )
 end

puts "Accepted: #{accepted.size}"
puts "Rejected: #{rejected.size}"

