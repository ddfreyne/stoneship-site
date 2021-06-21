# frozen_string_literal: true

Nanoc::Filter.define(:shy) do |content, _params = {}|
  content.gsub(/TypeScript/, 'Type&shy;Script')
end
