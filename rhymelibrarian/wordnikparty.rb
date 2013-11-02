# encoding: UTF-8
require 'httparty'

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
    rhymes.nil? || rhymes.size.zero? ? [] : rhymes[0]['words']
  end
end