# frozen_string_literal: true

require 'd-mark'

class DMarkTranslator < DMark::Translator
  include Nanoc::Helpers::HTMLEscape

  def handle_string(string, _context)
    [h(string)]
  end

  def handle_element(element, context)
    case element.name
    when 'h'
      handle_element_h(element, context)
    when 'highlight'
      handle_element_highlight(element, context)
    when 'firstterm'
      handle_element_firstterm(element, context)
    when 'listing'
      handle_element_listing(element, context)
    when 'section'
      handle_element_section(element, context)
    when 'contact'
      handle_element_contact(element, context)
    when 'ref'
      handle_element_ref(element, context)
    when 'em', 'strong', 'ul', 'ol', 'li', 'p', 'dl', 'dt', 'dd', 'table', 'tr', 'td', 'div', 'h1', 'h2', 'h3', 'code', 'b', 'i', 'pre', 'mark', 'span', 'a'
      handle_generic_element(element, context)
    else
      raise "Cannot translate #{element.name}"
    end
  end

  ###

  def handle_element_h(element, context)
    depth = context.fetch(:depth, 1)
    wrap("h#{depth}", id: id_for(element)) do
      wrap('span') do
        wrap('span') do
          handle_children(element, context)
        end
      end
    end
  end

  def handle_element_highlight(element, context)
    wrap('span', class: 'bg-green-200 dark:bg-green-800 -mx-1 px-1 rounded') { handle_children(element, context) }
  end

  def handle_element_firstterm(element, context)
    wrap('i') { handle_children(element, context) }
  end

  def handle_element_listing(element, context)
    lang = element.attributes['lang']
    code_attributes = lang ? { class: "language-#{lang}" } : {}
    wrap('pre', class: 'px-4 py-3 bg-blue-100 dark:bg-blue-900 rounded-md') do
      wrap('code', code_attributes) do
        handle_children(element, context)
      end
    end
  end

  def handle_element_contact(element, context)
    wrap('div', class: 'contact') { ['<span class="icon">✒</span> '] + handle_children(element, context) }
  end

  def handle_element_section(element, context)
    depth = context.fetch(:depth, 1)
    wrap('div', class: "l#{depth} section") do
      handle_children(element, context.merge(depth: depth + 1))
    end
  end

  def handle_element_ref(element, context)
    url = element.attributes.fetch('url')
    wrap('a', href: url) { handle_children(element, context) }
  end

  ###

  def handle_generic_element(element, context)
    wrap(element.name, element.attributes) do
      handle_children(element, context)
    end
  end

  ###

  def wrap(name, params = {})
    [
      start_tag(name, params),
      yield,
      end_tag(name),
    ]
  end

  def wrap_empty(name, params = {})
    [start_tag(name, params)]
  end

  def start_tag(name, params)
    '<' + name + params.map { |k, v| ' ' + k.to_s + '="' + html_escape(v) + '"' }.join('') + '>'
  end

  def end_tag(name)
    '</' + name + '>'
  end

  ###

  def text_content_of(node)
    case node
    when String
      node
    when DMark::ElementNode
      node.children.map { |c| text_content_of(c) }.join
    else
      raise "Unknown node type: #{node.class}"
    end
  end

  def id_for(element)
    @_id_for_cache ||= {}
    @_id_for_ids ||= Set.new

    @_id_for_cache.fetch(element) do
      id = to_id(text_content_of(element))
      id << '-' while @_id_for_ids.include?(id)
      @_id_for_ids << id
      @_id_for_cache[element] = id
    end
  end

  def to_id(string)
    string.downcase.gsub(/\W+/, '-').gsub(/^-|-$/, '')
  end
end

Nanoc::Filter.define(:dmark) do |content, _params = {}|
  nodes = DMark::Parser.new(content).parse
  context = { items: @items, item: @item, config: @config, nodes: nodes }
  DMarkTranslator.translate(nodes, context)
rescue StandardError => e
  case e
  when DMark::Parser::ParserError
    line = content.lines[e.line_nr]

    lines = [
      e.message,
      '',
      line,
      "\e[31m" + ' ' * [e.col_nr - 1, 0].max + '↑' + "\e[0m",
    ]

    fancy_msg = lines.map { |l| "\e[34m[D*Mark]\e[0m #{l.rstrip}\n" }.join('')
    raise "D*Mark parser error\n\n" + fancy_msg
  else
    raise e
  end
end
