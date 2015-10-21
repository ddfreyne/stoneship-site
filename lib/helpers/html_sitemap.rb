module StoneshipSite::Helpers

  module HTMLSitemap

    def html_sitemap_for(item, indentation=0, sitemap_buffer='')
      # Skip non-written or hidden items
      return sitemap_buffer if item.path.nil? || item[:is_hidden]

      # Open list element
      sitemap_buffer << "\t" * indentation + '<li>'

      # Add link
      sitemap_buffer << link_to_unless_current(item[:title], item.path)

      # Add children to sitemap, recursively
      children = @items.find_all(item.identifier.without_exts + '/*')
      visible_children = children.select { |child| !child[:is_hidden] && !child.binary? && child.path }
      visible_children = visible_children.sort_by { |item| (item[:title] || '').downcase }
      if visible_children.size > 0
        # Open list
        sitemap_buffer << "\t" * indentation + '<ul>' + "\n"

        # Add children
        visible_children.each do |child|
          html_sitemap_for(child, indentation+1, sitemap_buffer)
        end

        # Close list
        sitemap_buffer << "\t" * indentation + '</ul>' + "\n"
      end

      # Close list element
      sitemap_buffer << '</li>'

      # Return sitemap
      sitemap_buffer
    end

  end

end
