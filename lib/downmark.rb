# turndown_service.rb
# rubocop:disable all
require "nokogiri"
require_relative "downmark/utilities"
require_relative "downmark/node"
require_relative "downmark/rules"

class Downmark
  def initialize(options = {})
    defaults = {
      heading_style: "setext",
      hr: "* * *",
      bullet_list_marker: "*",
      code_block_style: "indented",
      fence: "```",
      em_delimiter: "_",
      strong_delimiter: "**",
      link_style: "inlined",
      link_reference_style: "full",
      br: "",
      preformatted_code: false,
      blank_replacement: proc { |_content, node|
        node.is_block? ? "\n\n" : ""
      },
      keep_replacement: proc { |_content, node|
        node.is_block? ? "\n\n#{node.node.to_html}\n\n" : node.node.to_html
      },
      default_replacement: proc { |content, node|
        node.is_block? ? "\n\n#{content}\n\n" : content
      }
    }

    @options = Utilities.extend({}, defaults, options)
    @rules = Rules.new(@options)
  end

  def convert(input)
    raise TypeError, "#{input} is not a String or Nokogiri node" unless can_convert?(input)

    return "" if input.strip.empty?

    root = create_root_node(input)
    output = process(root)
    post_process(output)
  end

  def use(plugin)
    case plugin
    when Array
      plugin.each { |p| use(p) }
    when Proc
      plugin.call(self)
    else
      raise TypeError, "plugin must be a Proc or an Array of Procs"
    end
    self
  end

  def add_rule(key, rule)
    @rules.add(key, rule)
    self
  end

  def keep(filter)
    @rules.keep(filter)
    self
  end

  def remove(filter)
    @rules.remove(filter)
    self
  end

  def process(parent_node)
    parent_node.children.reduce("") do |output, child|
      node = Node.new(child, @options)
      replacement = if node.text?
                      node.is_code? ? node.content : escape(node.content)
                    elsif node.element?
                      replacement_for_node(node)
                    else
                      ""
                    end
      join_lines(output, replacement)
    end
  end

  private

  def can_convert?(input)
    input.is_a?(String) || input.is_a?(Nokogiri::XML::Node)
  end

  def create_root_node(input)
    if input.is_a?(String)
      fragment = Nokogiri::HTML::DocumentFragment.parse("<div id='turndown-root'>#{input}</div>")
      root = fragment.at_css("#turndown-root")
    else
      root = input.dup
    end

    collapse_whitespace(
      element: root,
      is_block: method(:is_block?),
      is_void: method(:is_void?),
      is_pre: @options[:preformatted_code] ? method(:is_pre_or_code?) : proc { |node| node.name.downcase == "pre" }
    )

    root
  end

  def replacement_for_node(node)
    rule = @rules.for_node(node)
    content = process(node.node)
    whitespace = node.flanking_whitespace
    content.strip! if whitespace[:leading].empty? && whitespace[:trailing].empty?

    # Adjust for replacement functions that may need turndown_service
    replacement = if rule[:replacement].arity == 4
                    rule[:replacement].call(content, node, @options, self)
                  else
                    rule[:replacement].call(content, node, @options)
                  end

    "#{whitespace[:leading]}#{replacement}#{whitespace[:trailing]}"
  end

  def post_process(output)
    @rules.for_each do |rule|
      if rule[:append].is_a?(Proc)
        append_content = rule[:append].call(@options)
        output = join_lines(output, append_content) if append_content
      end
    end
    output.strip
  end

  def join_lines(output, replacement)
    s1 = Utilities.trim_trailing_newlines(output)
    s2 = Utilities.trim_leading_newlines(replacement)
    nls = [output.length - s1.length, replacement.length - s2.length].max
    separator = "\n\n"[0...nls]
    s1 + separator + s2
  end

  def escape(string)
    Utilities::ESCAPES.reduce(string) do |str, (pattern, replacement)|
      str.gsub(pattern, replacement)
    end
  end

  def is_block?(node)
    Utilities.is_block?(node)
  end

  def is_void?(node)
    Utilities.is_void?(node)
  end

  def is_pre_or_code?(node)
    %w[pre code].include?(node.name.downcase)
  end

  def collapse_whitespace(options)
    element = options[:element]
    is_block = options[:is_block]
    is_void = options[:is_void]
    is_pre = options[:is_pre] || proc { |node| node.name.downcase == "pre" }

    return unless element.children.any? && !is_pre.call(element)

    if @options[:debug]
      puts "Collapsing whitespace for #{element.name}"
      puts " ㄴis_block: #{is_block.call(element)}"
      puts " ㄴis_void: #{is_void.call(element)}"
      puts " ㄴis_pre: #{is_pre.call(element)}"
    end

    prev_text = nil
    keep_leading_ws = false

    prev = nil
    node = next_node(prev, element, is_pre)

    while node != element
      if node.text? || node.cdata?
        text = node.content.gsub(/[ \r\n\t]+/, " ")

        if (!prev_text || prev_text.content =~ / $/) &&
           !keep_leading_ws && text.start_with?(" ")
          text = text[1..-1]
        end

        if text.empty?
          node = remove(node)
          next
        end

        node.content = text
        prev_text = node
      elsif node.element?
        if is_block.call(node) || node.name.downcase == "br"
          prev_text.content = prev_text.content.sub(/ $/, "") if prev_text
          prev_text = nil
          keep_leading_ws = false
        elsif is_void.call(node) || is_pre.call(node)
          prev_text = nil
          keep_leading_ws = true
        elsif prev_text
          keep_leading_ws = false
        end
      else
        node = remove(node)
        next
      end

      next_node_temp = next_node(prev, node, is_pre)
      prev = node
      node = next_node_temp
    end

    return unless prev_text

    prev_text.content = prev_text.content.sub(/ $/, "")
    remove(prev_text) if prev_text.content.empty?
  end

  def remove(node)
    next_node = node.next_sibling || node.parent
    node.remove
    next_node
  end

  def next_node(prev, current, is_pre)
    if (prev && prev.parent == current) || is_pre.call(current)
      current.next_sibling || current.parent
    else
      current.children.first || current.next_sibling || current.parent
    end
  end
end
