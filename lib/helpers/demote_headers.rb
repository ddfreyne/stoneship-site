module StoneshipSite::Helpers
  module DemoteHeaders
    # Shifts all headers one level down, e.g. turns h2 into h3.
    def demote_headers(s)
      s.gsub('<h5', '<h6')
       .gsub('</h5', '</h6')
       .gsub('<h4',  '<h5')
       .gsub('</h4', '</h5')
       .gsub('<h3',  '<h4')
       .gsub('</h3', '</h4')
       .gsub('<h2',  '<h3')
       .gsub('</h2', '</h3')
       .gsub('<h1',  '<h2')
       .gsub('</h1', '</h2')
    end
  end
end
