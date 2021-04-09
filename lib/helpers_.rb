# frozen_string_literal: true

include Nanoc::Helpers::XMLSitemap
include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Breadcrumbs

def classes_for_note_li(note)
  if note[:tags].include?('#stage/blooming')
    'list-icon-star'
  else
    ''
  end
end
