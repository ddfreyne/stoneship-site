# frozen_string_literal: true

Nanoc::Filter.define(:wikilinks) do |content, _params = {}|
  content
    .gsub(/\[\[[^\]]+\]\]/) do |match|
      title = match[2..-3]
      next if title.strip.empty?

      link_target = @items.find_all('/notes/*').find { |i| i[:title] == title }
      if link_target
        "[#{title}](#{link_target.reps[:default].path})"
      else
        raise "Broken reference to #{title}"
      end
    end
end
