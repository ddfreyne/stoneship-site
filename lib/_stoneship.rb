module StoneshipSite
  module Helpers
  end
end

# Returns the latest essay, article or review
def latest_item
  @items.select { |item| %w( article essay review ).include?(item[:kind]) }.
         sort_by { |item| item[:published_on] }.last
end


def format_date(date)
  "#{date.mon.to_mon_s} #{date.mday.ordinal}, #{date.year}"
end
