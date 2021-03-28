# frozen_string_literal: true

Nanoc::Filter.define(:wikilinks) do |content, _params = {}|
  content
    .gsub(/\[\[[^\]]+\]\]/) do |match|
      # Get contents between [ and ]
      title = match[2..-3]

      # Handle empty-nested-array case (special case)
      next if title.strip.empty?

      # Find note with matching title
      link_target = @items.find_all('/notes/*').find { |i| i[:title] == title }

      if link_target
        # Convert to Markdown link
        "[#{title}](#{link_target.reps[:default].path})"
      else
        raise "Broken reference to #{title}"
      end
    end
end
