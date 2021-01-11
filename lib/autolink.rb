# frozen_string_literal: true

Nanoc::Filter.define(:autolink) do |content, _params = {}|
  auto_link_re = %r{(https?://)[^\s<\u00A0"]+}i

  auto_link_cre = [
    /<[^>]+$/,
    /^[^>]*>/,
    /<a\b.*?>/i,
    %r{</a>}i,
  ]

  brackets = {
    ']' => '[',
    ')' => '(',
    '}' => '{'
  }

  content
    .gsub(auto_link_re) do
      match = Regexp.last_match

      href = match[0]

      is_auto_linked =
        (match.pre_match =~ auto_link_cre[0] and match.post_match =~ auto_link_cre[1]) ||
        (match.pre_match.rindex(auto_link_cre[2]) and Regexp.last_match.post_match !~ auto_link_cre[3])

      if is_auto_linked
        href
      else
        # don't include trailing punctuation character as part of the URL
        punctuation = []
        while href.sub!(%r{[^\p{Word}/-=&]$}, '')
          punctuation.push $&
          if (opening = brackets[punctuation.last]) && (href.scan(opening).size > href.scan(punctuation.last).size)
            href << punctuation.pop
            break
          end
        end

        link_to(href, href) + punctuation.reverse.join
      end
    end
end
