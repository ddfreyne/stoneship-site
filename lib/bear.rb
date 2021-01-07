# frozen_string_literal: true

Nanoc::Filter.define(:bear) do |content, _params = {}|
  tag_regex = /^#[a-zA-Z\/]+(\s+#[a-zA-Z\/]+)*/
  mark_regex = /::(.*)::/

  content
    .gsub(/\[\[[^\]]+\]\]/) do |match|
      # Replace [[wikilinks]]
      title = match[2..-3]
      link_target = @items.find_all('/notes/*').find { |i| i[:title] == title }
      if link_target
        "[#{title}](#{link_target.reps[:default].path})"
      else
        raise "Broken reference to #{title}"
      end
    end.gsub(tag_regex) do |match|
      # Replace #tags
      match.split(/\s+/).map { |m| '<span class="text-xs leading-none font-bold uppercase px-2 py-1 bg-gray-200 text-gray-700 rounded-full">' + m + '</span>' }.join(' ')
    end.gsub(mark_regex) do |match|
      # Replace ::marks::
      '<mark>' + match[2..-3] + '</mark>'
    end
end
