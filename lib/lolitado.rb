$:.unshift File.expand_path('..', __FILE__)

require 'lolitado/pool'
require 'lolitado/db'
require 'lolitado/api'
require 'lolitado/box'

#
# Module that when included adds functionality to an API(Rest/Graph) Class.
# 
# How to use it ?
# 
# @example Rest API
#   class TestRest
#     include Lolitado

#     def initialize
#       base_uri 'https://xxx.com'
#     end

#     def get_details_of_a_city city_slug, locale
#       request('get', "/cities/#{city_slug}", locale)
#     end
#   end
#
# @example Graph API
#   class TestGraph
#     include Lolitado

#     def initialize
#       base_uri 'https://xxx.com'
#     end

#     def user_login payload
#       query = "mutation login($input: UserLoginInput!) {userLogin(input:$input) {authToken}}"
#       graph_request(query, payload)
#     end
#   end
module Lolitado

  #
  # forward request method from Rest class to API.request method
  # 
  # @param method [String] http request method
  # @param endpoint [String] http request endpoint
  # @param token [String] authorization token if query needed
  # @param locale [String] locale if query needed
  # @param body [String] http request body
  #
  def request method, endpoint, token = false, locale = false, body=false
    add_headers({'Authorization' => "Bearer #{token}"}) if token
    add_headers({'Accept-Language' => locale}) if locale
    API.request(method, endpoint, body)
  end

  #
  # forward graph_request method from Graph class to Graph.request method
  #
  # @param query [String] graph query
  # @param token [String] authorization token if query needed
  # @param locale [String] locale if query needed
  # @param variables [String] input variables for graph query using
  #
  def graph_request query, token = false, locale = false, variables = false
    add_headers({'Content-Type' => "application/json"})
    add_headers({'Authorization' => "Bearer #{token}"}) if token
    add_headers({'Accept-Language' => locale}) if locale
    Graph.request(query, variables)
  end
  
  #
  # forward add_headers from Rest/Graph class to API.add_headers method
  # 
  # @param value [Hash] http header value
  #
  def add_headers value
    API.add_headers value
  end

  #
  # forward uri from Rest/Graph class to API.uri method
  #
  # @param uri [String] http request uri
  #
  def base_uri uri
    API.base_uri uri
  end

end
