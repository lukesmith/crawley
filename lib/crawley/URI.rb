module URI

  # @param root [URI]
  # @param page_path [String]
  # @param href [String]
  # @return [URI]
  def self.make_absolute(root, page_path, href)
    href = href.split('#')[0]
    root_url = root.to_s

    if href.start_with?('/')
      result = root_url + URI.unescape(href)
    else
      root_url = root_url + page_path if page_path.end_with?('/')
      root_url = root_url + '/' unless root_url.end_with?('/')
      result = root_url + URI.unescape(href)
    end

    URI.parse(URI.escape(result))
  end

end