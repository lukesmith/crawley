require 'csv'
require 'crawley/http'

class LinkVerifier

  def initialize(path, csv_file)
    @path = URI.parse(path)
    @csv_file = csv_file
    @failed_paths = []
  end

  def verify
    http = HTTP.new

    CSV.foreach(@csv_file) do |row|
      http.head @path + row[0]
      @failed_paths += http.failed_paths
    end

    @failed_paths.each do |path|
      puts "\t#{path}".color(:red).bright
    end
  end

  def make_request(url)
    found = false
    until found
      puts "\tmaking request to #{url}"
      host, port = url.host, url.port if url.host && url.port
      req = Net::HTTP::Head.new(url.path)
      response = Net::HTTP.start(host, port) {|http|  http.request(req) }

      if response.kind_of?(Net::HTTPOK)
        found = true
      elsif response.kind_of?(Net::HTTPRedirection)
        url = URI.parse(response.header['location'])

        unless url.host == @path.host
          found = true
        end
      else
        @failed_paths << url
      end
    end
  end

end