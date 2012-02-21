require 'bozo_scripts'

test_with :runit do |p|
  p.path 'test/**/*_tests.rb'
end

package_with :rubygems

resolve_dependencies_with :bundler

post_publish :git_tag_release

with_hook :teamcity
with_hook :git_commit_hashes