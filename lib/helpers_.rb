# frozen_string_literal: true

include Nanoc::Helpers::Blogging
include Nanoc::Helpers::XMLSitemap
include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Breadcrumbs

def meta_robots
  values = []

  if @item[:index].equal?(false)
    values << 'noindex'
  end

  if @item[:follow].equal?(false)
    values << 'nofollow'
  end

  if values.any?
    %[<meta name="robots" content="#{values.join(', ')}">]
  else
    ''
  end
end

def sorted_articles
  @items
    .find_all('/articles/*')
    .sort_by { |i| Date.parse(i[:published_on]) }
    .reverse
end

def articles_by_year
  @items
    .find_all('/articles/*')
    .group_by { |i| Date.parse(i[:published_on]).year }
    .transform_values { |is| is.sort_by { |i| i[:title].downcase.gsub(/[^a-z]/, '') } }
end
