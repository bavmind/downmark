require "nokogiri"

def collapse_whitespace(options)
  element = options[:element]
  is_block = options[:is_block]
  is_void = options[:is_void]
  is_pre = options[:is_pre] || proc { |node| node.name == "pre" }

  return if !element.child || is_pre.call(element)

  prev_text = nil
  keep_leading_ws = false

  prev = nil
  node = next_node(prev, element, is_pre)

  while node != element
    if node.text? || node.cdata?
      text = node.content.gsub(/[ \r\n\t]+/, " ")

      text = text[1..-1] if (!prev_text || prev_text.content =~ / $/) && !keep_leading_ws && text.start_with?(" ")

      if text.empty?
        node = remove(node)
        next
      end

      node.content = text
      prev_text = node
    elsif node.element?
      if is_block.call(node) || node.name == "br"
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
    current.child || current.next_sibling || current.parent
  end
end

# # Define your is_block and is_void functions
# is_block = proc { |node| %w[div p h1 h2 h3 h4 h5 h6 ul ol li].include?(node.name) }
# is_void = proc { |node|
#   %w[area base br col embed hr img input link meta param source track wbr].include?(node.name)
# }

# # Parse your HTML content with Nokogiri
# html_content = "<div>   Some   text   <p>   More   text   </p>   </div>"
# doc = Nokogiri::HTML(html_content)

# # Call collapse_whitespace
# collapse_whitespace(
#   element: doc.at("body"),
#   is_block:,
#   is_void:
# )

# # Output the modified HTML
# puts doc.to_html
