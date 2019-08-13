$:.unshift File.expand_path('..', __FILE__)

require 'lolitado/pool'
require 'lolitado/db'
require 'lolitado/api'
require 'lolitado/box'

module Lolitado

  def request method, endpoint, body=false
    API.request(method, endpoint, body)
  end

  def graph_request query, variables = false
    Graph.request(query, variables)
  end

  def add_headers value
    API.add_headers value
  end

  def base_uri uri
    API.base_uri uri
  end

end
