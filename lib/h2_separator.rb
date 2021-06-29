# frozen_string_literal: true

require 'nokogiri'

Class.new(Nanoc::Filter) do
  identifiers :h2_separator

  def run(content, _arguments = {})
    doc = Nokogiri::HTML.fragment(content)
    doc.css('h2').each do |h2|
      div = Nokogiri::XML::Node.new('div', doc)
      div['class'] = 'h2-separator'

      h2.add_previous_sibling(div)
    end
    doc.to_s
  end
end
