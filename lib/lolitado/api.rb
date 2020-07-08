require 'httparty'
module Lolitado
  class API
    include HTTParty

    #
    # format api response
    #
    # @param response [String] api response
    # @param msecs [Float] benchmark for api response time
    #
    def self.format_response response, msecs
      new_response = {:response => response, :message => response.parsed_response, :status => response.code, :duration => msecs}
      response_with_hash_key = JSON.parse(JSON[new_response], symbolize_names: true)
      return response_with_hash_key
    end
    
    #
    # define a customize http request method for rest api, forward this method to call HTTParty.get or HTTParty.post or HTTParty.put
    # or HTTParty.delete method
    #
    # @param method [String] http request method
    # @param endpoint [String] http request endpoint
    # @param body [String] http request body
    #
    def self.request method, endpoint, body = false
      start = Time.now
      case method.to_s
      when "get"
        response = self.get(endpoint, :body => body, :headers => API.new_headers, :verify => false)
      when "post"
        response = self.post(endpoint, :body => body, :headers => API.new_headers, :verify => false)
      when "put"
        response = self.put(endpoint, :body => body, :headers => API.new_headers, :verify => false)
      when "delete"
        response = self.delete(endpoint, :headers => API.new_headers, :verify => false)
      else
        warn "#{method} is invalid http method."
      end
      finish = Time.now
      msecs = (finish - start) * 1000.0
      clear_headers
      # puts "RESPONSE - #{msecs}"
      return self.format_response(response, msecs)
    end 

    #
    # define a method to set http headers
    #
    # @param value [Hash] http header value
    #
    def self.add_headers value
      @new_headers ||= {}
      @new_headers = @new_headers.merge(value.to_hash)
      return @new_headers
    end

    #
    # define a method to get http headers
    #
    def self.new_headers
      return @new_headers
    end

    #
    # clear headers
    #
    def self.clear_headers
      API.new_headers.clear unless API.new_headers.nil?
    end
  end

  class Graph < API

    #
    #
    # define a customize http request method for graph api, forward this method to call HTTParty.get or HTTParty.post or HTTParty.put
    # or HTTParty.delete method
    #
    # @param query [String] graph query
    # @param variables [String] input variables for graph query using
    #
    def self.request query, variables = false
      super(:post, '', generate_body(query, variables))
    end

    #
    # format api response, override the parent method in API class
    #
    # @param response [String] api response
    # @param msecs [Float] benchmark for api response time
    #
    def self.format_response response, msecs
      if response.parsed_response.is_a?(Hash)
        if response.parsed_response.has_key?('errors')
          message = response.parsed_response
        else
          message = response.parsed_response['data'].values[0]
        end
      else
        message = {'errors'=>response.parsed_response}
      end
      new_response =  {:response => response, :message => message, :status => response.code, :duration => msecs}
      response_with_hash_key = JSON.parse(JSON[new_response], symbolize_names: true)
      return response_with_hash_key
    end

    # 
    # generate http request body for graph api response
    #
    # @param query [String] graph query
    # @param variables [String] input variables for graph query using
    #
    def self.generate_body query, variables
      body = {}
      body['query'] = query
      if variables
        variable_indices = query.enum_for(:scan, /(?=\$.*:)/).map { Regexp.last_match.offset(0).first }
        if query.include?('$input') && variable_indices.to_a.length == 1
          body['variables'] = {'input'=>variables}
        else
          body['variables'] = variables
        end
      end
      body['operationName'] = query.split(' ')[1].split('(')[0]
      return body.to_json
    end
  end
end

