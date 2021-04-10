# frozen_string_literal: true

Nanoc::Filter.define(:typography) do |content, _params = {}|
  non_breaking_space = ' '
  non_breaking_hyphen = '‑'

  doc = Nokogiri::HTML.fragment(content)

  doc.css('p').each do |para|
    last_text_child = para.children.select(&:text?).last
    next unless last_text_child

    # Replace non-breaking space
    last_text_child.content = last_text_child.content.sub(/ ([^ ]+)\z/, ' \1')
  end

  doc.css('.path').each do |path|
    parts = path.content.scan(%r{[/.-]|[^/.-]+})

    parts.unshift(nil) if parts.first.match?(%r{[/.-]})
    parts << nil if parts.last.match?(%r{[/.-]})
    # parts now has the format comp-sep-comp-...-comp-sep-comp
    # comp = component; sep = separator

    path.content = ''

    parts.each_slice(2) do |(comp, sep)|
      if comp
        path.add_child(Nokogiri::XML::Text.new(comp.gsub(/\s+/, non_breaking_space), doc))
        path.add_child(Nokogiri::XML::Node.new('wbr', doc))
      end

      if sep
        sep = non_breaking_hyphen if sep == '-'
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
