# frozen_string_literal: true

require 'nokogumbo'

Nanoc::Check.define(:dashes) do
  @output_filenames.each do |filename|
    next unless filename =~ /html$/

    doc = Nokogiri::HTML(File.read(filename))
    doc.css('.subtitle').each do |subtitle|
      add_issue('wrong dash detected (use en dash)', subject: filename) if subtitle.text =~ / - /
    end
  end
end

Nanoc::Check.define(:focus) do
  @output_filenames.each do |filename|
    next unless filename =~ /html$/

    foci = File.read(filename)[/focus/] || []
    if foci.size > 1
      add_issue(
        "don’t overuse focus", subject: filename)
    end
  end
end
