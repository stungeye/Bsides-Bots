require 'chatterbot/dsl'
require 'google-search'

SHORTENED_URL_ON_TWITTER = 23

no_update
verbose

# tweet "Hello world. I'm LMGTFY Bot, I Google things for you."

replies do |tweet|
  google_query = tweet.text.gsub(/@lmgtfyb /, '')
  feeling_lucky = Google::Search::Web.new(:query => google_query).first
  feeling_lucky_uri = feeling_lucky.uri
  feeling_lucky_title = "A 3D printed bust made last night at our local maker-space plus more text until this becomes way to long for a tweet."
  #feeling_lucky_title = feeling_lucky.title
  # Need to take the tweet_user's name length into consideration here:
  feeling_lucky_title = feeling_lucky_title.length < 117 ? 
    feeling_lucky_title : feeling_lucky_title.slice(0..113) + "..."
  puts "#{tweet_user(tweet)} #{feeling_lucky_title} #{feeling_lucky_uri}"
end
