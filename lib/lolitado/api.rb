require 'httparty'
module Lolitado
  class API
    include HTTParty

    #format api response
    def self.format_response response, msecs
      return {:response => response, :message => response.parsed_response, :status => response.code, :duration => msecs}
    end
    
    #define a customize http request method
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
      # puts "RESPONSE - #{msecs}"
      return self.format_response(response, msecs)
    end 

    def self.add_headers value
      @new_headers ||= {}
      @new_headers = @new_headers.merge(value.to_hash)
      return @new_headers
    end

    def self.new_headers
      return @new_headers
    end
  end

  class Graph < API

    def self.request query, variables = false
      super(:post, '/', generate_body(query, variables))
    end
  
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
      return {:response => response, :message => message, :status => response.code, :duration => msecs}
    end

    def self.generate_body query, variables
      body = {}
      body['query'] = query
      if variables
        if query.include?('$input')
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

