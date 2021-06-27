# frozen_string_literal: true

include Nanoc::Helpers::Blogging
include Nanoc::Helpers::XMLSitemap
include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Breadcrumbs

def meta_robots
  values = []

  values << 'noindex' if @item[:index].equal?(false)

  values << 'nofollow' if @item[:follow].equal?(false)

  if values.any?
    %(<meta name="robots" content="#{values.join(', ')}">)
  else
    ''
  end
end

def sorted_articles
  @items
    .find_all('/articles/*')
    .reject { |i| i[:draft] }
    .sort_by { |i| Date.parse(i[:published_on]) }
    .reverse
end
