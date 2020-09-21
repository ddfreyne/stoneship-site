# frozen_string_literal: true

Class.new(Nanoc::Filter) do
  identifier :toc

  def run(content, _params = {})
    content.gsub('::TOC::') do
      # Find all top-level sections
      doc = Nokogiri::HTML(content)
      headers = doc.css('h2, h3').map do |header|
        p header
        title = header['data-nav-title'] || header.inner_html
        { title: title, id: header['id'], level: header.name[/\d/].to_i }
      end

      next '' if headers.empty?

      # Build structure
      nested_headers = []
      headers.each do |header|
        case header[:level]
        when 2
          nested_headers << header.merge(children: [])
        when 3
          nested_headers.last[:children] << header
        else
          raise '???'
        end
      end

      # Build table of contents
      res = +'<ol class="pl-8">'
      nested_headers.each do |header|
        res << '<li>'
        res << %(<a href="##{header[:id]}">#{header[:title]}</a>)
        if header[:children].any?
          res << '<ol class="pl-7">'
          header[:children].each do |sub_header|
            res << '<li>'
            res << %(<a href="##{sub_header[:id]}">#{sub_header[:title]}</a>)
            res << '</li>'
          end
          res << '</ol>'
        end
        res << '</li>'
      end
      res << '</ol>'

      res
    end
  end
end
