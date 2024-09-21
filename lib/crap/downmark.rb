# frozen_string_literal: true

require "nokogiri"

require_relative "downmark/version"

block_elements = %w[
  ADDRESS ARTICLE ASIDE AUDIO BLOCKQUOTE BODY CANVAS
  CENTER DD DIR DIV DL DT FIELDSET FIGCAPTION FIGURE
  FOOTER FORM FRAMESET H1 H2 H3 H4 H5 H6 HEADER
  HGROUP HR HTML ISINDEX LI MAIN MENU NAV NOFRAMES
  NOSCRIPT OL OUTPUT P PRE SECTION TABLE TBODY TD
  TFOOT TH THEAD TR UL
]

void_elements = %w[
  AREA BASE BR COL COMMAND EMBED HR IMG INPUT
  KEYGEN LINK META PARAM SOURCE TRACK WBR
]

meaningful_when_blank_elements = %w[
  A TABLE THEAD TBODY TFOOT TH TD IFRAME SCRIPT
  AUDIO VIDEO
]

escapes = [
  [/\\/, "\\\\\\"],           # Escapes backslashes (e.g., "\" becomes "\\")
  [/\*/, "\\*"],              # Escapes asterisks (used for bold or italic in markdown)
  [/^-/, "\\-"],              # Escapes hyphens at the start of a line (used for lists)
  [/^\+ /, "\\\\+ "],         # Escapes plus signs at the start of a line (alternative list style)
  [/^(=+)/, "\\\\1"],         # Escapes a series of equal signs at the start of a line (used for heading underlines)
  [/^(\#{1,6}) /, "\\\\1 "],  # Escapes heading symbols (e.g., #, ##, ###) at the start of a line
  [/`/, "\\\\`"],             # Escapes backticks (used for inline code or code blocks)
  [/^~~~/, "\\~~~"],          # Escapes tildes at the start of a line (used for code blocks)
  [/\[/, "\\["],              # Escapes opening square brackets (used in markdown links)
  [/\]/, "\\]"],              # Escapes closing square brackets (used in markdown links)
  [/^>/, "\\>"],              # Escapes blockquote indicators (greater-than sign at the start of a line)
  [/_/, "\\_"],               # Escapes underscores (used for italic in markdown)
  [/^(\d+)\. /, "\\1\\. "]    # Escapes the period after a number at the start of a line (used for ordered lists)
]

# Test cases for each escape rule
test_cases = {
  "Backslash test" => ["This is a backslash: \\", "This is a backslash: \\\\"],
  "Asterisk test" => ["This is *bold*", "This is \\*bold\\*"],
  "Hyphen test" => ["- This is a list", "\\- This is a list"],
  "Plus sign test" => ["+ This is a list", "\\+ This is a list"],
  "Equals sign test" => ["== Heading underline", "\\1 Heading underline"],
  "Hash heading test" => ["# Heading", "\\1 Heading"],
  "Backtick test" => ["This is `code`", "This is \\`code\\`"],
  "Tilde code block test" => ["~~~ code block", "\\~~~ code block"],
  "Opening square bracket test" => ["This is [a link]", "This is \\[a link\\]"],
  "Closing square bracket test" => ["This is [a link]", "This is \\[a link\\]"],
  "Blockquote test" => ["> Blockquote", "\\> Blockquote"],
  "Underscore test" => ["This is _italic_", "This is \\_italic\\_"],
  "Ordered list test" => ["1. Item", "1\\. Item"]
}

# Apply escape rules and test them
test_cases.each do |test_name, (input, expected)|
  result = input.dup
  escapes.each { |pattern, replacement| result.gsub!(pattern, replacement) }

  if result == expected
    puts "#{test_name}: Passed"
  else
    puts "#{test_name}: Failed (Expected: #{expected}, Got: #{result})"
  end
end
