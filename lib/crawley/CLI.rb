$:.push File.expand_path(File.dirname(__FILE__))

require 'rainbow'
require 'gli'
require 'gli_version'

require 'crawley'
require 'crawley/version'

include GLI

version Crawley::VERSION

desc 'verify the urls from a csv'
command :verify, :v do |c|
  c.action do |global_options, options, args|
    Crawley::UrlVerifier.new '', args[0]
  end
end

desc 'crawls the url'
command :crawl, :c do |c|
  c.action do |global_options, options, args|
    Crawley::Crawley::run args[0]
  end
end