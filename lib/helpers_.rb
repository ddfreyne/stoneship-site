include Nanoc::Helpers::XMLSitemap

Nanoc::Filter.define :add_header_wrappers do |content|
  content
    .gsub('<h2>', '<h2><span><span>')
    .gsub('</h2>', '</span></span></h2>')
end
