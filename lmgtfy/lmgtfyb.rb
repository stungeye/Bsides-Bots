require 'chatterbot/dsl'
require 'google-search'

# Twitter will shorten URLS to 23 character and we'll be adding a
# space before the URL so the max length is 140 - 23 - 1 = 116.
MAX_TWEET_LENGTH = 116

# The bot name plus a space needs to be striped from the received tweets
# to determine the search query.
BOT_NAME = '@lmgtfyb '

# If we truncate a title we'll put this at the end of the string.
TRUNCATION_INDICATOR = '...'

# Remove these lines once we start running this via cron.
#no_update
#verbose

replies do |tweet|
  user_who_tweeted = tweet_user(tweet)
  
  google_query_received = tweet.text.gsub(BOT_NAME, '')
  feeling_lucky = Google::Search::Web.new(:query => google_query_received).first
  
  response_with_at_reply = "#{user_who_tweeted} #{feeling_lucky.title}"
  
  if response_with_at_reply.length > MAX_TWEET_LENGTH
    response_with_at_reply = response_with_at_reply[0...(MAX_TWEET_LENGTH-TRUNCATION_INDICATOR.size)] + TRUNCATION_INDICATOR
  end
  
  full_response_tweet = "#{response_with_at_reply} #{feeling_lucky.uri}"
  
  reply full_response_tweet, tweet
  
  sleep 1
end
