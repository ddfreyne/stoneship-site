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
    when 'subtitle'
      handle_element_subtitle(element, context)
    when 'section'
      handle_element_section(element, context)
    when 'contact'
      handle_element_contact(element, context)
    when 'ref'
      handle_element_ref(element, context)
    when 'em', 'ul', 'li', 'p', 'dl', 'dt', 'dd', 'table', 'tr', 'td'
      handle_generic_element(element, context)
    else
      raise "Cannot translate #{element.name}"
    end
  end

  ###

  def handle_element_h(element, context)
    depth = context.fetch(:depth, 1)
    wrap("h#{depth}", id: id_for(element)) do
      handle_children(element, context)
    end
  end

  def handle_element_subtitle(element, context)
    wrap('div', class: 'subtitle') { handle_children(element, context) }
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
    wrap(element.name) do
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

  # def handle_string(string, context)
  #   if context.fetch(:html_escape, true)
  #     [h(string)]
  #   else
  #     [string]
  #   end
  # end

  # def extra_attributes_for_element(element, _context)
  #   attributes = {}

  #   # dt, section, h
  #   attributes[:id] = element.attributes['id'] if element.attributes['id']

  #   attributes[:class] = 'legacy' if element.attributes['legacy']
  #   attributes[:class] = 'errors' if element.attributes['errors']
  #   attributes[:class] = 'legacy-intermediate' if element.attributes['legacy-intermediate']
  #   attributes[:class] = 'new' if element.attributes['new']

  #   case element.name
  #   when 'h'
  #     attributes['data-nav-title'] = element.attributes['nav-title'] if element.attributes['nav-title']
  #   when 'dl', 'figure'
  #     attributes[:class] = 'compact' if element.attributes['compact']
  #   when 'ol', 'ul'
  #     attributes[:class] = 'spacious' if element.attributes['spacious']
  #   end

  #   attributes
  # end

  # # Abstract methods

  # def handle_element(element, context)
  #   case element.name
  #   when 'ref'
  #     handle_ref(element, context)
  #   when 'entity'
  #     handle_entity(element, context)
  #   when 'erb'
  #     handle_erb(element, context)
  #   when 'listing'
  #     handle_listing(element, context)
  #   when 'caption'
  #     wrap('figcaption') { handle_children(element, context) }
  #   when 'firstterm', 'identifier', 'glob', 'filename', 'class', 'command', 'prompt', 'productname', 'see', 'log-create', 'log-check-ok', 'log-check-error', 'log-update', 'uri', 'attribute', 'output'
  #     wrap('span', class: element.name) { handle_children(element, context) }
  #   when 'note', 'tip', 'caution', 'todo'
  #     wrap('div', class: "admonition-wrapper #{element.name}") do
  #       wrap('div', class: 'admonition') do
  #         handle_children(element, context)
  #       end
  #     end
  #   when 'code', 'kbd', 'figure', 'blockquote', 'var', 'strong'
  #     attributes = {}

  #     attributes[:class] = 'compact' if element.attributes['compact'] # figure

  #     wrap(element.name, attributes) { handle_children(element, context) }
  #   when 'swatch'
  #     attributes = { class: "swatch swatch-#{element.attributes.fetch('color')}" }
  #     wrap(element.name, attributes) do
  #       wrap('span', class: 'inside') do
  #         handle_children(element, context)
  #       end
  #     end
  #   else
  #     super
  #   end
  # end

  # # Specific elements

  # def handle_entity(node, context)
  #   entity = text_content_of(node)

  #   content =
  #     case entity
  #     when 'sudo-gem-install'
  #       SUDO_GEM_INSTALL_CONTENT_DMARK
  #     when 'sudo-gem-update-system'
  #       SUDO_GEM_UPDATE_SYSTEM_CONTENT_DMARK
  #     end

  #   nodes = DMark::Parser.new(content).read_inline_content
  #   [NanocWsHTMLTranslator.translate(nodes, context)]
  # end

  # def handle_erb(node, context)
  #   ctx = Nanoc::Int::Context.new(context)
  #   [eval(text_content_of(node), ctx.get_binding)] # rubocop:disable Security/Eval
  # end

  # def handle_listing(element, context)
  #   pre_classes = []
  #   pre_classes << 'template' if element.attributes['template']
  #   pre_classes << 'errors' if element.attributes['errors']
  #   pre_classes << 'legacy' if element.attributes['legacy']
  #   pre_classes << 'legacy-49' if element.attributes['legacy-49']
  #   pre_classes << 'legacy-intermediate' if element.attributes['legacy-intermediate']
  #   pre_classes << 'new' if element.attributes['new']
  #   pre_classes << 'new-49' if element.attributes['new-49']
  #   pre_attrs =
  #     if pre_classes.any?
  #       { class: pre_classes.join(' ') }
  #     else
  #       {}
  #     end

  #   code_attrs =
  #     if element.attributes['lang']
  #       { class: 'language-' + element.attributes['lang'] }
  #     else
  #       {}
  #     end

  #   wrap('pre', pre_attrs) do
  #     wrap('code', code_attrs) do
  #       if element.attributes['lang']
  #         addition = translate(element.children, context.merge(html_escape: false))
  #         CodeRay.scan(addition, element.attributes['lang']).html
  #       else
  #         translate(element.children, context)
  #       end
  #     end
  #   end
  # end

  # def handle_ref_with_url(node, context, url)
  #   wrap('a', href: url) { handle_children(node, context) }
  # end

  # def handle_ref_with_content(node, context, target_item, frag)
  #   href = href_for(target_item, frag)
  #   wrap('a', href: href) { handle_children(node, context) }
  # end

  # def handle_ref_bare(_node, _context, target_item, frag, target_node)
  #   href = href_for(target_item, frag)
  #   wrap('a', href: href) do
  #     if frag
  #       text_content_of(target_node)
  #     else
  #       target_item[:title]
  #     end
  #   end
  # end

  # def handle_ref_insert_section_ref(_node, _context, target_item, frag, target_node)
  #   href = href_for(target_item, frag)
  #   header_content =
  #     header_content_of(target_node).sub(/^The /, '').sub(/^./, &:upcase)

  #   [
  #     'the ',
  #     wrap('a', href: href) { header_content },
  #     ' section',
  #   ]
  # end

  # def handle_ref_insert_inside_ref(_node, _context, _target_item, _frag, _target_node)
  #   [
  #     ' on ',
  #   ]
  # end

  # def handle_ref_insert_chapter_ref(_node, _context, target_item, _frag)
  #   [
  #     'the ',
  #     wrap('a', href: target_item.path) { target_item[:title] },
  #     ' page',
  #   ]
  # end

  # def handle_ref_insert_end(_node, _context, _target_item, _frag, _target_node)
  #   []
  # end

  # def href_for(target_item, frag)
  #   if frag
  #     target_item.path + '#' + frag
  #   else
  #     target_item.path
  #   end
  # end
end

Nanoc::Filter.define(:dmark) do |content, params = {}|
  begin
    nodes = DMark::Parser.new(content).parse
    context = { items: @items, item: @item, config: @config, nodes: nodes }
    DMarkTranslator.translate(nodes, context)
  rescue => e
    handle_error(e, content)
  end
end
