# encoding: UTF-8
require 'httparty'

# The official Wordnik API Ruby gem wasn't working for me,
# so I built this HTTParty wrapper for finding rhymes.

class WordnikParty
  include HTTParty
  
  API_VERSION = 'v4'.freeze
  base_uri "http://api.wordnik.com/#{API_VERSION}/word.json/"
  format :json
  
  def initialize(key)
    self.class.default_params :api_key => key
  end
  
  def q(method, options = {})
    response = self.class.get(method, :query => options)
    response.parsed_response
  end
  
  def rhymes_with(word, word_limit = 10)
    options = {
      'relationshipTypes' => 'rhyme',
      'limitPerRelationshipType' => word_limit,
      'useCanonical' => 'false'
    }
    rhymes = q("/#{word}/relatedWords", options)
    rhymes.nil? || rhymes.size.zero? || rhymes.is_a?(Hash) ? [] : rhymes[0]['words']
  end
end