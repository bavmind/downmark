# rules.rb
require_relative "utilities"

class Rules
  attr_reader :rules

  def initialize(options)
    @options = options
    @keep = []
    @remove = []
    @rules = []
    define_rules
  end

  def add(key, rule)
    @rules.unshift(rule)
  end

  def keep(filter)
    @keep.unshift({
                    filter:,
                    replacement: @options[:keep_replacement]
                  })
  end

  def remove(filter)
    @remove.unshift({
                      filter:,
                      replacement: proc { "" }
                    })
  end

  def for_node(node)
    return @blank_rule if node.is_blank?

    find_rule(@rules, node) ||
      find_rule(@keep, node) ||
      find_rule(@remove, node) ||
      @default_rule
  end

  def for_each(&)
    @rules.each(&)
  end

  private

  def define_rules
    @blank_rule = {
      replacement: @options[:blank_replacement]
    }

    @default_rule = {
      replacement: @options[:default_replacement]
    }

    add(:paragraph, {
          filter: "p",
          replacement: proc { |content, _node, _options|
            "\n\n#{content}\n\n"
          }
        })

    add(:line_break, {
          filter: "br",
          replacement: proc { |_content, _node, options|
            "#{options[:br]}\n"
          }
        })

    add(:heading, {
          filter: %w[h1 h2 h3 h4 h5 h6],
          replacement: proc { |content, node, options|
            h_level = node.node.name[1].to_i
            if options[:heading_style] == "setext" && h_level < 3
              underline = Utilities.repeat(h_level == 1 ? "=" : "-", content.length)
              "\n\n#{content}\n#{underline}\n\n"
            else
              "\n\n#{Utilities.repeat("#", h_level)} #{content}\n\n"
            end
          }
        })

    add(:blockquote, {
          filter: "blockquote",
          replacement: proc { |content, _node, _options|
            content = content.strip.gsub(/^/m, "> ")
            "\n\n#{content}\n\n"
          }
        })

    add(:list, {
          filter: %w[ul ol],
          replacement: proc { |content, node, _options|
            parent = node.node.parent
            if parent.name.downcase == "li" && parent.children.last == node.node
              "\n#{content}"
            else
              "\n\n#{content}\n\n"
            end
          }
        })

    add(:list_item, {
          filter: "li",
          replacement: proc { |content, node, options|
            content = content.gsub(/^\n+/, "").gsub(/\n+$/, "\n").gsub("\n", "\n    ")
            prefix = options[:bullet_list_marker] + "   "
            parent = node.node.parent
            if parent.name.downcase == "ol"
              start = parent["start"] ? parent["start"].to_i : 1
              index = parent.element_children.index(node.node)
              prefix = "#{start + index}.  "
            end
            content = content.strip
            "#{prefix}#{content}\n"
          }
        })

    add(:code_block, {
          filter: proc { |node, options|
            (options[:code_block_style] == "fenced") &&
              node.node.name.downcase == "pre" &&
              node.element_children.first &&
              node.element_children.first.name.downcase == "code"
          },
          replacement: proc { |_content, node, options|
            code_node = node.node.element_children.first
            language = code_node["class"].to_s[/language-(\S+)/, 1] || ""
            code = code_node.text.rstrip
            fence = options[:fence] * 3
            "\n\n#{fence}#{language}\n#{code}\n#{fence}\n\n"
          }
        })

    add(:horizontal_rule, {
          filter: "hr",
          replacement: proc { |_content, _node, options|
            "\n\n#{options[:hr]}\n\n"
          }
        })

    add(:inline_link, {
          filter: proc { |node, options|
            (options[:link_style] == "inlined") &&
              node.node.name.downcase == "a" &&
              node.node["href"]
          },
          replacement: proc { |content, node, _options|
            href = node.node["href"].to_s.gsub(/[()]/, '\\\\\0')
            title = node.node["title"] ? " \"#{node.node["title"].gsub('"', '\"')}\"" : ""
            "[#{content}](#{href}#{title})"
          }
        })

    add(:reference_link, {
          filter: proc { |node, options|
            (options[:link_style] == "referenced") &&
              node.name.downcase == "a" &&
              node["href"]
          },
          replacement: proc { |content, node, options|
            href = node.node["href"]
            title = node.node["title"] ? " \"#{node.node["title"]}\"" : ""
            id = @references.length + 1
            @references << "[#{id}]: #{href}#{title}"
            "[#{content}][#{id}]"
          },
          references: [],
          append: proc { |options|
            references = @references.join("\n")
            @references.clear
            "\n\n#{references}\n\n" unless references.empty?
          }
        })

    add(:emphasis, {
          filter: %w[em i],
          replacement: proc { |content, _node, options|
            content.strip.empty? ? "" : "#{options[:em_delimiter]}#{content}#{options[:em_delimiter]}"
          }
        })

    add(:strong, {
          filter: %w[strong b],
          replacement: proc { |content, _node, options|
            content.strip.empty? ? "" : "#{options[:strong_delimiter]}#{content}#{options[:strong_delimiter]}"
          }
        })

    add(:code, {
          filter: proc { |node, _options|
            node.node.name.downcase == "code" &&
              node.node.parent.name.downcase != "pre"
          },
          replacement: proc { |content, _node, _options|
            content = content.strip.gsub(/\r?\n|\r/, " ")
            delimiter = "`"
            matches = content.scan(/`+/)
            delimiter += "`" while matches.include?(delimiter)
            "#{delimiter}#{content}#{delimiter}"
          }
        })

    add(:image, {
          filter: "img",
          replacement: proc { |_content, node, _options|
            alt = node.node["alt"].to_s
            src = node.node["src"].to_s
            title = node.node["title"] ? " \"#{node.node["title"]}\"" : ""
            src.empty? ? "" : "![#{alt}](#{src}#{title})"
          }
        })

    # Indented code block
    add(:indented_code_block, {
          filter: proc { |node, options|
            options[:code_block_style] == "indented" &&
              node.node.name.downcase == "pre" &&
              node.node.element_children.any? &&
              node.node.element_children.first.name.downcase == "code"
          },
          replacement: proc { |_content, node, _options|
                         code_node = node.node.element_children.first
                         code = code_node.text.rstrip
                         indented_code = code.gsub(/\n$/, "").gsub(/^/, "    ")
                         "\n\n#{indented_code}\n\n"
                       }
        })

    # Fenced code block
    add(:fenced_code_block, {
          filter: proc { |node, options|
            options[:code_block_style] == "fenced" &&
              node.node.name.downcase == "pre" &&
              node.node.element_children.any? &&
              node.node.element_children.first.name.downcase == "code"
          },
          replacement: proc { |_content, node, options|
                         code_node = node.node.element_children.first
                         class_name = code_node["class"] || ""
                         language = class_name[/language-(\S+)/, 1] || ""
                         code = code_node.text

                         # Adjust fence size if needed
                         fence_char = options[:fence][0]
                         fence_size = 3
                         fence_in_code_regex = Regexp.new("^" + Regexp.escape(fence_char) + "{3,}", Regexp::MULTILINE)

                         code.scan(fence_in_code_regex) do |match|
                           fence_size = [fence_size, match.length + 1].max
                         end

                         fence = fence_char * fence_size

                         "\n\n#{fence}#{language}\n#{code.rstrip}\n#{fence}\n\n"
                       }
        })

    # Table rules
    add(:table_cell, {
          filter: proc { |node, _options|
            %w[th td].include?(node.node.name.downcase) && is_in_data_table?(node)
          },
          replacement: proc { |content, node, _options, turndown_service|
            cell_content = turndown_service.process(node.node)
            cell_content = cell_content.strip.gsub("\n", " ").gsub("|", '\\|')
            cell_content = " " if cell_content.empty?
            cell_content
          }
        })

    add(:table_row, {
          filter: proc { |node, _options|
            node.node.name.downcase == "tr" && is_in_data_table?(node)
          },
          replacement: proc { |content, node, _options, _turndown_service|
                         is_header = is_heading_row?(node)
                         cells = content.strip.split(/\s*\|\s*/).reject(&:empty?)
                         row = "| " + cells.join(" | ") + " |"

                         if is_header
                           separator = "| " + cells.map { |cell| "-" * [3, cell.length].max }.join(" | ") + " |"
                           "\n#{row}\n#{separator}"
                         else
                           "\n#{row}"
                         end
                       }
        })

    add(:table_header, {
          filter: "thead",
          replacement: proc { |content, node, _options, turndown_service|
                         # Process header cells to get their content length
                         header_cells = node.node.css("th").map do |cell|
                           cell_content = turndown_service.process(cell)
                           cell_content = cell_content.strip.gsub("\n", " ").gsub("|", '\\|')
                           cell_content = " " if cell_content.empty?
                           cell_content
                         end

                         # Build the separator line based on header cell lengths
                         separator = header_cells.map do |cell_content|
                           "-" * [3, cell_content.length].max
                         end.join(" | ")

                         separator_line = "| #{separator} |\n"

                         (content + "\n" + separator_line)
                       }
        })

    add(:table_body, {
          filter: "tbody",
          replacement: proc { |content, _node, _options|
                         content
                       }
        })

    add(:table, {
          filter: proc { |node, _options|
            is_data_table?(node)
          },
          replacement: proc { |content, _node, _options|
                         "\n\n#{content.strip}\n\n"
                       }
        })

    # Initialize reference storage for reference links
    @references = []
  end

  def is_data_table?(node)
    # A heuristic: if the table contains any <th> elements, consider it a data table
    node.node.css("th").any?
  end

  # Helper method to determine if a node is inside a data table
  def is_in_data_table?(node)
    table_node = node.node.ancestors("table").first
    table_node && is_data_table?(Node.new(table_node, @options))
  end

  # Helper method to determine if a row is a header row
  def is_heading_row?(node)
    node.node.css("th").any?
  end

  def find_rule(rules, node)
    rules.find { |rule| filter_value(rule[:filter], node) }
  end

  def filter_value(filter, node)
    case filter
    when String
      filter == node.node.name.downcase
    when Array
      filter.map(&:downcase).include?(node.node.name.downcase)
    when Proc
      filter.call(node, @options)
    else
      false
    end
  end
end
