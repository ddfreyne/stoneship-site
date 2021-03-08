# frozen_string_literal: true

Nanoc::Filter.define(:footnotes) do |content, _params = {}|
  doc = Nokogiri::HTML.fragment(content)

  # Remove reverse footnotes (footnote backlinks)
  # (These will not be needed later on anyway)
  doc.css('.reversefootnote').each(&:remove)

  # Collect footnotes
  footnotes_map = {}
  doc.css('.footnotes > ol > li').each do |footnote|
    footnote_id = footnote['id'].sub(/^fn:/, '')
    footnotes_map[footnote_id] =
      footnote
        .children
        .reject { |n| n.text? && n.content.strip == '' }
        .flat_map { |n| n.element? && n.name == 'p' ? n.children : [] }
  end

  # Remove footnotes
  doc.css('.footnotes').each(&:remove)

  # Insert sidenotes
  doc.css('sup[id]').each do |sup|
    footnote_id = sup['id'].sub(/^fnref:/, '')
    footnote_content = footnotes_map[footnote_id]

    sidenote_content = footnote_content.map(&:to_html).join('')
    sidenote_markup = <<~SIDENOTE_MARKUP.strip
      <span class="sidenote"
        ><input
          aria-label="Show sidenote"
          type="checkbox"
          id="sidenote__checkbox--#{footnote_id}"
          class="sidenote__checkbox"
        ><label
          tabindex="0"
          title=""
          aria-describedby="sidenote-#{footnote_id}"
          for="sidenote__checkbox--#{footnote_id}"
          class="sidenote__label"
        >&lowast;</label
        ><small
          id="sidenote-#{footnote_id}"
          class="sidenote__content"
        >#{sidenote_content}</small
      ></span>
    SIDENOTE_MARKUP

    sup.replace(sidenote_markup)
  end

  doc.to_s
end
