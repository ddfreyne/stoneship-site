# frozen_string_literal: true

Nanoc::Filter.define(:mark) do |content, _params = {}|
  mark_regex = /::(.*)::/

  content
    .gsub(mark_regex) do |match|
      # Get contents between :: pair
      marked_raw = match[2..-3]

      # Convert from Markdown to HTML
      marked_html = ::Kramdown::Document.new(marked_raw).to_html

      # Strip surrounding <p> and </p>
      marked_html_clean = marked_html.gsub(%r{</?p>}, '')

      "<mark>#{marked_html_clean}</mark>"
    end
end
