require 'chatterbot/dsl'
require 'google-search'
require 'cgi'

# Twitter will shorten URLS to 23 character and we'll be adding a
# space before the URL so the max length is 140 - 23 - 1 = 116.
MAX_TWEET_LENGTH = 116

# The bot name plus a space needs to be striped from the received tweets
# to determine the search query.
BOT_NAME = '@lmgtfyb '

# If we truncate a title we'll put this at the end of the string.
TRUNCATION_INDICATOR = '...'

NO_RESULTS_FOUND = 'Ever so sorry; I found no websites that reference: '

# Remove these lines once we start running this via cron.
#debug_mode
#no_update
#verbose

replies do |user_tweet|
  user_who_tweeted = tweet_user(user_tweet)
  
  google_query_received = user_tweet.text.gsub(/[#\@]\w+\b/,'').strip
  
  feeling_lucky = Google::Search::Web.new(:query => google_query_received).first

  response_tweet = user_who_tweeted + " "

  if feeling_lucky.nil?
    response_tweet += NO_RESULTS_FOUND + google_query_received 
  else
    response_tweet += CGI.unescapeHTML(feeling_lucky.title)
  end
    
  if response_tweet.length > MAX_TWEET_LENGTH
    response_tweet = response_tweet[0...(MAX_TWEET_LENGTH-TRUNCATION_INDICATOR.size)] + TRUNCATION_INDICATOR
  end
  
  response_tweet += " " + feeling_lucky.uri  unless feeling_lucky.nil?

  reply response_tweet, user_tweet
  
  sleep 1
end
