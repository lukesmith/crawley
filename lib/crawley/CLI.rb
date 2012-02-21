$:.push File.expand_path(File.dirname(__FILE__))

require 'rainbow'
require 'gli'
require 'gli_version'

require 'crawley'
require 'version'
require 'url_verifier'

include GLI

version Crawley::VERSION

desc 'verify the urls from a csv'
command :verify, :v do |c|
  c.action do |global_options, options, args|
    path = File.expand_path File.join(args[0])
    verifier = Crawley::UrlVerifier.new args[1], path
    verifier.verify
  end
end

desc 'crawls the url'
command :crawl, :c do |c|
  c.action do |global_options, options, args|
    Crawley::Crawley::run args[0]
  end
end