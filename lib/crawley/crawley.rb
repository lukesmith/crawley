require 'uri'
require 'csv'
require 'FileUtils'

require 'nokogiri'
require 'crawley/http'
require 'rainbow'

class Crawley

  def self.run
    url = URI.parse('http://localhost:9292')

    crawley = Crawley.new url
    crawley.crawl
    crawley.generate_csv File.expand_path 'temp/temp.csv'

    puts "Number of 404s: #{crawley.not_found.length}"
    crawley.not_found.keys.each do |u|
      puts "   #{u}"
    end

    puts "Number of 500s: #{crawley.errors.length}"
    crawley.errors.keys.each do |u|
      puts "   #{u}"
    end
  end

  def initialize(url)
    @root_url = url
  end

  def crawl
    current_url = @root_url
    @visited_urls = Hash.new
    pending_urls = []

    until current_url.nil?
      @visited_urls[current_url] = Hash.new
      html = parse_url current_url

      unless html.nil?
        found_urls = find_urls current_url, html
        @visited_urls[current_url][:links] = found_urls.length
        urls = found_urls.uniq - @visited_urls.keys
        pending_urls = pending_urls + urls
        pending_urls.uniq!
      end

      current_url = pending_urls.pop
    end
  end

  def generate_csv(path)
    FileUtils.mkdir_p File.dirname path
    CSV.open(path, "wb") do |csv|
      @visited_urls.keys.each do |url|
        csv << [url.to_s, @visited_urls[url][:code], @visited_urls[url][:links]]
      end
    end
  end

  def not_found
    @visited_urls.select { |url| @visited_urls[url][:code] == '404' }
  end

  def errors
    @visited_urls.select { |url| @visited_urls[url][:code] == '500' }
  end

  def parse_url(url)
    http = Http.new
    response = http.get url
    @visited_urls[url][:code] = response.code
    return nil if response.body.nil? or response.body.empty?
    Nokogiri.HTML(response.body)
  end

  def find_urls(page_url, document)
    document.css('a').select { |a| valid_href? a[:href] }.map { |a| get_url page_url, a[:href] }
  end

  def get_url(page_url, href)
    url = href.split('#')[0]
    if relative?(url)
      make_absolute page_url, url
    else
      URI.parse(@root_url.to_s + '/' + url)
    end
  end

  def make_absolute(page_url, url)
    if url.start_with?('/')
      result = URI.parse(URI.escape(@root_url.to_s + URI.unescape(url)))
    else
      path = url
      path = '/' + url unless url.start_with?('/')
      result = URI.parse(page_url.to_s.split('/')[0..-2].join('/') + path)
    end

    result
  end

  def relative?(url)
    url.start_with?('/') or !url.start_with?('http')
  end

  def valid_href?(href)
    if !href.nil? &&
        href.length > 0 &&
        !href.start_with?('#') &&
        !href.start_with?('javascript:') &&
        !href.start_with?('https://' &&
        !href.start_with?('mailto:'))
      url = URI.parse(URI.escape(href))
      url.host.nil? && (url.scheme == 'http' || url.scheme.nil?)
    end
  end

end