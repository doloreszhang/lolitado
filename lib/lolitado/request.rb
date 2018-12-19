require 'httparty'

class Request
  include HTTParty

  attr_accessor :new_headers
  # debug_output $stdout

  def new_response response, msecs
    new_response = {}
    new_response.merge({:response => response, :message => response.parsed_response, :status => response.code, :duration => msecs})
  end

  def request base_uri, method, endpoint, body = false
    url = base_uri + endpoint
    case method
    when "get"
      start = Time.now
      response = self.class.get(url, :body => body, :headers => new_headers, :verify => false)
      finish = Time.now
    when "post"
      start = Time.now
      response = self.class.post(url, :body => body, :headers => new_headers, :verify => false)
      finish = Time.now
    when "put"
      start = Time.now
      response = self.class.put(url, :body => body, :headers => new_headers, :verify => false)
      finish = Time.now
    when "delete"
      start = Time.now
      response = self.class.delete(url, :headers => new_headers, :verify => false)
      finish = Time.now
    else
      puts "#{method} is invalid method."
      exit
    end
    msecs = (finish - start) * 1000.0
    return new_response(response, msecs)
  end

  def add_headers value
    @new_headers ||= {}
    @new_headers = @new_headers.merge(value.to_hash)
    return @new_headers
  end
end
