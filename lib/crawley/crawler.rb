require 'crawley/URI'
require 'crawley/http'

class Crawler

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
    http = HTTP.new
    response = http.get url
    @visited_urls[url][:code] = response.code
    return nil if response.body.nil? or response.body.empty?
    Nokogiri.HTML(response.body)
  end

  def find_urls(page_url, document)
    document.css('a').select { |a| valid_href? a[:href] }.map do |a|
      URI.make_absolute @root_url, page_url.to_s, a[:href]
    end
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