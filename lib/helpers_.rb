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
