# frozen_string_literal: true

Nanoc::Filter.define(:typography) do |content, _params = {}|
  doc = Nokogiri::HTML.fragment(content)

  doc.css('p').each do |para|
    para.children.each do |child|
      next unless child.text?

      # Replace non-breaking space
      child.content = child.content.sub(/ ([^ ]+)\z/, ' \1')
    end
  end

  doc.css('.path').each do |path|
    parts = path.content.split('/')
    parts << '' if path.content.end_with?('/')

    path.content = ''

    parts.each.with_index do |part, idx|
      unless idx.zero?
        path.add_child(Nokogiri::XML::Node.new('wbr', doc))
        path.add_child(Nokogiri::XML::Text.new('/', doc))
      end

      path.add_child(Nokogiri::XML::Text.new(part.sub(/\s+/, ' '), doc))
    end
  end

  doc.traverse do |elem|
    next unless elem.text?

    # wrap em dashes with thin spaces
    elem.content = elem.content.gsub(/\s*—\s*/, "\u2009—\u2009")
  end

  doc.to_s
end
