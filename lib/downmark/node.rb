# node.rb
require_relative "utilities"

class Node
  attr_reader :node, :is_block, :is_code, :is_blank, :flanking_whitespace

  def initialize(nodey, options)
    @node = nodey
    @options = options
    @is_block = Utilities.is_block?(node)
    @is_code = nodey.name.downcase == "code" || (nodey.parent && nodey.parent.name.downcase == "code")
    @is_blank = blank?
    @flanking_whitespace = compute_flanking_whitespace
  end

  def text?
    node.text?
  end

  def element?
    node.element?
  end

  def content
    node.content
  end

  def is_block?
    @is_block
  end

  def is_code?
    @is_code
  end

  def is_blank?
    @is_blank
  end

  private

  def blank?
    !Utilities.is_void?(node) &&
      !Utilities.is_meaningful_when_blank?(node) &&
      node.to_s.strip.empty? &&
      !Utilities.has_void?(node) &&
      !Utilities.has_meaningful_when_blank?(node)
  end

  def compute_flanking_whitespace
    return { leading: "", trailing: "" } if is_block? || (@options[:preformatted_code] && is_code?)

    content = node.content
    leading_ws = content[/\A([ \t\r\n]*)(\s*)/, 1] || ""
    trailing_ws = content[/(\s*)([ \t\r\n]*)\z/, 2] || ""

    # Debug whitspaces
    # { leading: "LEADING_WS", trailing: "TRAILING_WS" }
    { leading: leading_ws, trailing: trailing_ws }
  end
end
