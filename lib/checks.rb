# frozen_string_literal: true

require 'nokogumbo'

Nanoc::Check.define(:focus) do
  @output_filenames.each do |filename|
    next unless filename =~ /html$/

    contents = File.read(filename)
    num_foci = (contents[/focus/] || []).size
    if num_foci / contents.size.to_f > 0.005
      add_issue(
        "don’t overuse focus", subject: filename)
    end
  end
end

Nanoc::Check.define(:footnotes) do
  @output_filenames.each do |filename|
    next unless filename =~ /html$/

    contents = File.read(filename)
    if contents =~ /\[\^/
      add_issue(
        "broken footnote reference", subject: filename)
    end
  end
end
