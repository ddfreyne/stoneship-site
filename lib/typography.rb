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
    parts = path.content.scan(%r{[/.]|[^/.]+})

    parts.unshift(nil) if parts.first.match?(%r{[/.]})
    parts << nil if parts.last.match?(%r{[/.]})
    # parts now has the format comp-sep-comp-...-comp-sep-comp
    # comp = component; sep = separator

    path.content = ''

    parts.each_slice(2) do |(comp, sep)|
      if comp
        path.add_child(Nokogiri::XML::Text.new(comp.gsub(/\s+/, ' '), doc))
        path.add_child(Nokogiri::XML::Node.new('wbr', doc))
      end

      if sep
        path.add_child(Nokogiri::XML::Text.new(sep, doc))
      end
    end
  end

  doc.traverse do |elem|
    next unless elem.text?

    # wrap em dashes with thin spaces
    elem.content = elem.content.gsub(/\s*—\s*/, "\u2009—\u2009")
  end

  doc.to_s
end
