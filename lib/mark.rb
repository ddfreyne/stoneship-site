# frozen_string_literal: true

Nanoc::Filter.define(:mark) do |content, _params = {}|
  mark_regex = /::(.*)::/

  content
    .gsub(mark_regex) do |match|
      marked_content = match[2..-3]
      '<mark>' + ::Kramdown::Document.new(marked_content).to_html.gsub(%r{</?p>}, '') + '</mark>'
    end
end
