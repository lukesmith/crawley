require 'test_helper'
require 'crawley/URI'

class URIMakeAbsoluteTests < Test::Unit::TestCase

  def setup
    @root_url = URI.parse("http://localhost")
  end

  def test_relative_to_root
    assert_equal URI.parse('http://localhost/car'), URI.make_absolute(@root_url, "/", "/car")
  end

  def test_relative_to_root2
    assert_equal URI.parse('http://localhost/car'), URI.make_absolute(@root_url, "/products", "/car")
  end

  def test_relative_to_root_with_space
    assert_equal URI.parse('http://localhost/blue%20car'), URI.make_absolute(@root_url, "/", "/blue car")
  end

  def test_path_is_empty
    assert_equal URI.parse('http://localhost'), URI.make_absolute(@root_url, "", "")
  end

  def test_path_is_root
    assert_equal URI.parse('http://localhost/'), URI.make_absolute(@root_url, "/", "/")
  end

  def test_path_relative_to_page
    assert_equal URI.parse('http://localhost/car'), URI.make_absolute(@root_url, "/products", 'car')
  end

  def test_path_relative_to_page2
    assert_equal URI.parse('http://localhost/products/car'), URI.make_absolute(@root_url, "/products/", 'car')
  end

end