require 'csv'
require 'crawley/http'

module Crawley
  class UrlVerifier

    def initialize(hostname, csv_file)
      @hostname = URI.parse(hostname)
      @csv_file = csv_file
      @failed_paths = []
    end

    def verify
      http = HTTP.new

      CSV.foreach(@csv_file) do |row|
        url = @hostname + URI.escape(row[0])
        if url.host == @hostname.host
          http.head url
          @failed_paths += http.failed_paths
        end
      end

      @failed_paths.each do |path|
        puts "\t#{path}".color(:red).bright
      end
    end

  end
end