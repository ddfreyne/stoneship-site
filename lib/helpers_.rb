include Nanoc::Helpers::XMLSitemap

Nanoc::Filter.define :add_header_wrappers do |content|
  content
    .gsub('<h2>', '<h2><span>')
    .gsub('</h2>', '</span></h2>')
end
