require 'uri'
require 'csv'
require 'FileUtils'

require 'nokogiri'
require 'rainbow'

require 'crawley/crawler'

class Crawley

  def self.run
    url = URI.parse('http://localhost:9292')

    crawler = Crawler.new url
    crawler.crawl
    crawler.generate_csv File.expand_path 'temp/temp.csv'

    puts "Number of 404s: #{crawler.not_found.length}"
    crawler.not_found.keys.each do |u|
      puts "   #{u}"
    end

    puts "Number of 500s: #{crawler.errors.length}"
    crawler.errors.keys.each do |u|
      puts "   #{u}"
    end
  end

end