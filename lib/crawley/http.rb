require 'net/http'
require 'uri'
require 'rainbow'

class Http

  def exists?(url)
    found = false
    res = nil
    until found
      puts "    making request to #{url}"
      host, port = url.host, url.port if url.host && url.port
      req = Net::HTTP::Head.new(url.path)
      res = Net::HTTP.start(host, port) {|http|  http.request(req) }
      res.header['location'] ? url = URI.parse(res.header['location']) : found = true

      unless url.host == 'localhost'
        found = true
      end
    end

    res
  end

  def get(url)
    found = false
    res = nil
    hops = 0
    until found
      puts "    making request to #{url}"
      host, port = url.host, url.port if url.host && url.port
      path = url.path.nil? || url.path.empty? ? '/' : url.path
      req = Net::HTTP::Get.new(path)
      res = Net::HTTP.start(host, port) {|http| http.request(req) }
      redirect_url = nil
      res.header['location'] ? redirect_url = URI.parse(res.header['location']) : found = true

      unless redirect_url.nil?
        found = (redirect_url.host != url.host) || (hops == 3)
        hops = hops + 1
      end
    end

    res
  end

end