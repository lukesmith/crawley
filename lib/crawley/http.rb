require 'net/http'

class HTTP

  def initialize
    @failed_paths = []
  end

  def failed_paths
    @failed_paths
  end

  def head(url)
    @failed_paths = []
    make_request url, Net::HTTP::Head
  end

  def get(url)
    make_request url, Net::HTTP::Get
  end

  private

  def make_request(url, request_type)
    found = false
    hops = 0
    until found
      puts "\tmaking request to #{url}"
      host, port = url.host, url.port if url.host && url.port
      path = url.path.nil? || url.path.empty? ? '/' : url.path
      response = Net::HTTP.start(host, port) {|http|  http.request(request_type.new(path)) }

      if response.kind_of?(Net::HTTPOK)
        found = true
      elsif response.kind_of?(Net::HTTPRedirection)
        hops = hops + 1
        redirect_url = URI.parse(response.header['location'])

        if redirect_url.host == url.host
          url = redirect_url
        else
          found = true
        end

        found = true if hops == 4
      else
        @failed_paths << url
        found = true
      end
    end

    response
  end

end