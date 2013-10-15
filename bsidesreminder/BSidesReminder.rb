require 'chatterbot/dsl'
require 'date'

# remove this to send out tweets
debug_mode

# remove this to update the db
no_update
# remove this to get less output when running
verbose

BSIDES_WINNIPEG_2013_DATE = Date.parse('November 16 2013')

puts BSIDES_WINNIPEG_2013_DATE
