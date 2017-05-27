module StoneshipSite::Helpers
  module Ratings
    def rating_stars_for(item)
      full_star  = '<span class="full">&#9733;</span>'
      empty_star = '<span class="empty">&#9734;</span>'

      '<span class="rating">' +
        (full_star  * item[:rating]) +
        (empty_star * (5 - item[:rating])) +
        '</span>'
    end
  end
end
