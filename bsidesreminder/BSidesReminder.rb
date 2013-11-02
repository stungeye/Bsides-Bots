require 'date'

BSIDES_WINNIPEG_2013_DATE = Date.parse('November 16 2013')
days_until_bsides = (BSIDES_WINNIPEG_2013_DATE - Date.today).to_i

if days_until_bsides < 0 
  exit
end

sleep 30

require 'chatterbot/dsl'

tweet_text = "@stungeye You are presenting @BSidesWpg "

if days_until_bsides.zero?
  tweet_text += "today!"
elsif days_until_bsides == 1
  tweet_text += "tomorrow."
else
  tweet_text += "in #{days_until_bsides} days."
end

tweet tweet_text
