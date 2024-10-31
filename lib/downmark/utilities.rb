# utilities.rb
module Utilities
  BLOCK_ELEMENTS = %w[
    ADDRESS ARTICLE ASIDE AUDIO BLOCKQUOTE BODY CANVAS
    CENTER DD DIR DIV DL DT FIELDSET FIGCAPTION FIGURE
    FOOTER FORM FRAMESET H1 H2 H3 H4 H5 H6 HEADER
    HGROUP HR HTML ISINDEX LI MAIN MENU NAV NOFRAMES
    NOSCRIPT OL OUTPUT P PRE SECTION TABLE TBODY TD
    TFOOT TH THEAD TR UL
  ]

  VOID_ELEMENTS = %w[
    AREA BASE BR COL COMMAND EMBED HR IMG INPUT
    KEYGEN LINK META PARAM SOURCE TRACK WBR
  ]

  MEANINGFUL_WHEN_BLANK_ELEMENTS = %w[
    A TABLE THEAD TBODY TFOOT TH TD IFRAME SCRIPT
    AUDIO VIDEO
  ]

  ESCAPES = [
    [/\\/, "\\\\\\\\"],
    # [/\*/, '\\\\*'], # disabled for inside-strong-test
    [/^-(\s)/, '\\-\\1'],
    # [/^\+ /, '\\\\+ '], disabled for escaping-ul-markdown-+
    # [/^(=+)/, '\\\\\1'], # this seams to break tests
    [/^(\#{1,6}) /, '\\\\\1 '],
    [/`/, '\\\\`'],
    [/^~~~/, '\\\\~~~'],
    [/\[/, '\\\\['],
    [/\]/, '\\\\]'],
    # [/^>/, '\\\\>'], # disabled since it breaks "espaping > as blockquote" test
    # [/_/, '\\\\_'], # disable for name escaping-strong-markdown-with-_
    [/^(\d+)\. /, '\\\\\1. ']
  ]

  def self.extend(destination, *sources)
    sources.each do |source|
      source.each do |key, value|
        destination[key] = value
      end
    end
    destination
  end

  def self.repeat(character, count)
    character * count
  end

  def self.trim_leading_newlines(string)
    string.sub(/\A\n+/, "")
  end

  def self.trim_trailing_newlines(string)
    string.sub(/\n+\z/, "")
  end

  def self.is_block?(node)
    BLOCK_ELEMENTS.include?(node.name.upcase)
  end

  def self.is_void?(node)
    VOID_ELEMENTS.include?(node.name.upcase)
  end

  def self.has_void?(node)
    node.css(VOID_ELEMENTS.join(",")).any?
  end

  def self.is_meaningful_when_blank?(node)
    MEANINGFUL_WHEN_BLANK_ELEMENTS.include?(node.name.upcase)
  end

  def self.has_meaningful_when_blank?(node)
    node.css(MEANINGFUL_WHEN_BLANK_ELEMENTS.join(",")).any?
  end
end
