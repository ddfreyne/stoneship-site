# frozen_string_literal: true

require 'nokogiri'

Class.new(Nanoc::Filter) do
  identifiers :run_in_headers

  def run(content, _arguments = {})
    doc = Nokogiri::HTML.fragment(content)
    doc.css('h3 + p').each do |para|
      h3 = para.previous
      h3 = h3.previous while h3.text?

      div = Nokogiri::XML::Node.new('div', doc)
      div['class'] = 'run-in'
      div.add_child(h3.dup)
      div.add_child(para.dup)

      para.add_next_sibling(div)

      h3.unlink
      para.unlink
    end
    doc.to_s
  end
end
