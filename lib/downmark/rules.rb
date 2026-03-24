# rubocop:disable all

require_relative "utilities"

class Rules
  HIGHLIGHT_REGEXP = /highlight-(?:text|source)-([a-z0-9]+)/

  attr_reader :rules

  def initialize(options)
    @options = options
    @options[:debug] ||= false
    @options[:debug_with_html] ||= true  # set to true to output HTML content in debug messages
    @keep = []
    @remove = []
    @rules = []
    define_rules
  end

  def add(key, rule)
    rule[:name] = key
    @rules.unshift(rule)
  end

  def keep(filter)
    @keep.unshift({
                    name: 'keep',
                    filter: filter,
                    replacement: @options[:keep_replacement]
                  })
  end

  def remove(filter)
    @remove.unshift({
                      name: 'remove',
                      filter: filter,
                      replacement: proc { "" }
                    })
  end


  def for_node(node)

    if node.is_blank?
      puts "   ㄴ Applying blank_rule since node is_blank" if @options[:debug]
      return @blank_rule
    end


    rule = find_rule(@rules, node) ||
           find_rule(@keep, node) ||
           find_rule(@remove, node) ||
           @default_rule

    if rule == @default_rule
      puts "   ㄴ Applying default rule to node #{node.node.name.downcase}" if @options[:debug]
    end
    rule
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
            content = content.gsub(/\A\n+/, "").gsub(/\n+\z/, "\n")
            content = content.gsub(/\n([^\n])/, "\n    \\1")
            prefix = options[:bullet_list_marker] + "   "
            parent = node.node.parent
            if parent.name.downcase == "ol"
              prefix = "#{ordered_list_item_number(node.node)}.  "
            end
            has_next_list_item = node.node.xpath("following-sibling::*").any?
            needs_loose_spacing = has_next_list_item &&
              node.node.element_children.any? { |child| child.name.downcase == "p" }
            suffix = if needs_loose_spacing
              "\n"
            elsif has_next_list_item && content !~ /\n\z/
              "\n"
            else
              ""
            end

            "#{prefix}#{content}#{suffix}"
          }
        })

    add(:code_block, {
          filter: proc { |node, options|
            (options[:code_block_style] == "fenced") &&
              node.node.name.downcase == "pre" &&
              node.node.element_children.first &&
              node.node.element_children.first.name.downcase == "code"
          },
          replacement: proc { |_content, node, options|
            code_node = node.node.element_children.first
            language = code_node["class"].to_s[/language-(\S+)/, 1] || ""
            code = code_node.text.sub(/\n\z/, "")
            fence = options[:fence] * 3
            "\n\n#{fence}#{language}\n#{code}\n#{fence}\n\n"
          }
        })

    add(:highlighted_code_block, {
          filter: proc { |node, _options|
            next false unless node.node.name.downcase == "div"

            first_child = node.node.element_children.first
            class_names = node.node["class"].to_s.split

            class_names.any? { |class_name| class_name.match?(HIGHLIGHT_REGEXP) } &&
              first_child &&
              first_child.name.downcase == "pre"
          },
          replacement: proc { |_content, node, options|
            class_name = node.node["class"].to_s.split.find { |name| name.match?(HIGHLIGHT_REGEXP) }.to_s
            language = class_name[HIGHLIGHT_REGEXP, 1] || ""

            "\n\n#{options[:fence]}#{language}\n#{node.node.element_children.first.text}\n#{options[:fence]}\n\n"
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
        options[:link_style] == "inlined" &&
          node.node.name.downcase == "a" &&
          node.node["href"]
      },
      replacement: proc { |content, node, _options|
        href = node.node["href"]
        title = if node.node["title"]
          title_text = node.node["title"].gsub('"', '\"')
          # Replace multiple newlines with a single newline and remove leading spaces
          title_text = title_text.split(/\n+/).map(&:lstrip).join("\n")
          " \"#{title_text}\""
        else
          ""
        end
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

        if content.start_with?("`")
          "#{delimiter} #{content} #{delimiter}"
        else
          "#{delimiter}#{content}#{delimiter}"
        end
      }
    })




    add(:image, {
          filter: "img",
          replacement: proc { |_content, node, _options|
            alt = if node.node["alt"]
              alt_text = node.node["alt"].to_s.gsub('"', '\"')
              # Replace multiple newlines with a single newline and remove leading spaces
              alt_text = alt_text.split(/\n+/).map(&:lstrip).join("\n")
              "#{alt_text}"
            else
              ""
            end
            src = node.node["src"].to_s
            title = if node.node["title"]
              alt_title = node.node["title"].to_s.gsub('"', '\"')
              # Replace multiple newlines with a single newline and remove leading spaces
              alt_title = alt_title.split(/\n+/).map(&:lstrip).join("\n")
              " \"#{alt_title}\""
            else
              ""
            end
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
                         indented_code = code.split("\n", -1).map { |line| line.empty? ? "" : "    #{line}" }.join("\n")
                         "\n\n#{indented_code}\n\n"
                       }
        })

    # Strikethrough
    add(:strikethrough, {
          filter: %w[del s strike],
          replacement: proc { |content, _node, _options|
            content.strip.empty? ? "" : "~#{content}~"
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
                         code = code_node.text.sub(/\n\z/, "")

                         # Adjust fence size if needed
                         fence_char = options[:fence][0]
                         fence_size = 3
                         fence_in_code_regex = Regexp.new("^#{Regexp.escape(fence_char)}{3,}", Regexp::MULTILINE)

                         code.scan(fence_in_code_regex) do |match|
                           fence_size = [fence_size, match.length + 1].max
                         end

                         fence = fence_char * fence_size

                         "\n\n#{fence}#{language}\n#{code}\n#{fence}\n\n"
                       }
        })

    # Table rules
    add(:table_keep, {
      filter: proc { |node, _options|
        node.node.name.downcase == "table" && !convertible_table?(node.node)
      },
      replacement: proc { |_content, node, _options|
        "\n\n#{serialized_table_html(node.node)}\n\n"
      }
    })

    add(:table_cell, {
      filter: %w[th td],
      replacement: proc { |content, node, _options|
        table_cell(content.strip.gsub("\n", " "), node.node)
      }
    })

    add(:table_row, {
      filter: "tr",
      replacement: proc { |content, node, _options|
        next "" if empty_table_row?(node.node)

        border_cells = ""
        align_map = { "left" => ":--", "right" => "--:", "center" => ":-:" }

        if is_heading_row?(node.node)
          node.node.element_children.each do |child|
            border = "---"
            align = child["align"].to_s.downcase
            border = align_map[align] || border unless align.empty?
            border_cells += table_cell(border, child)
          end
        end

        output = "\n#{content}"
        output += "\n#{border_cells}" unless border_cells.empty?
        output
      }
    })

    add(:table, {
      filter: proc { |node, _options|
        node.node.name.downcase == "table" && convertible_table?(node.node)
      },
      replacement: proc { |content, _node, _options|
        "\n\n#{content.gsub("\n\n", "\n")}\n\n"
      }
    })

    add(:table_section, {
      filter: %w[thead tbody tfoot],
      replacement: proc { |content, _node, _options|
        content
      }
    })

    # Initialize reference storage for reference links
    @references = []
  end

  def ordered_list_item_number(list_item_node)
    parent = list_item_node.parent
    current_number = parent["start"] ? parent["start"].to_i : 1

    parent.element_children.each do |child|
      current_number = child["value"].to_i if child["value"]
      return current_number if child == list_item_node

      current_number += 1
    end

    current_number
  end

  def convertible_table?(table_node)
    return true if @options[:treat_all_tables_as_data_tables]

    first_row = table_node.css("tr").first
    first_row && is_heading_row?(first_row)
  end

  def table_cell(content, node)
    index = node.parent.element_children.index(node)
    prefix = index.zero? ? "| " : " "
    "#{prefix}#{content} |"
  end

  def empty_table_row?(row_node)
    cells = row_node.element_children.select { |child| %w[th td].include?(child.name.downcase) }
    cells.any? && cells.all? { |cell| cell.content.strip.empty? }
  end

  def serialized_table_html(table_node)
    table = table_node.dup(1)

    unless table.css("thead,tbody,tfoot").any?
      direct_rows = table.element_children.select { |child| child.name.downcase == "tr" }
      if direct_rows.any?
        tbody = Nokogiri::XML::Node.new("tbody", table.document)
        direct_rows.each do |row|
          tbody.add_child(row.remove)
        end
        table.add_child(tbody)
      end
    end

    table.to_html.gsub(/>\s+</, "><").strip
  end

  # Helper method to determine if a row is a header row
  def is_heading_row?(row_node)
    parent_node = row_node.parent
    parent_name = parent_node.name.downcase

    return true if parent_name == "thead"

    first_row = parent_node.element_children.find { |child| child.name.downcase == "tr" }
    return false unless first_row == row_node
    return false unless parent_name == "table" || first_tbody?(parent_node)

    row_node.element_children.all? { |child| child.name.downcase == "th" }
  end

  def first_tbody?(element)
    return false unless element.name.downcase == "tbody"

    previous_sibling = element.previous_sibling
    while previous_sibling&.text? && previous_sibling.text.strip.empty?
      previous_sibling = previous_sibling.previous_sibling
    end

    previous_sibling.nil? ||
      (previous_sibling.name.downcase == "thead" && previous_sibling.text.strip.empty?)
  end


  def find_rule(rules, node)
    rule = rules.find { |rule| filter_value(rule[:filter], node) }
    if rule
      puts_debug_info(rule[:name], node)
    end
    rule
  end

  def puts_debug_info(rule_name, node)
    if @options[:debug]
      if @options[:debug_with_html]
        html_content = node.node.to_html.strip
        puts "   ㄴ Applying rule \e[31m#{rule_name}\e[0m to node \e[32m#{node.node.name.downcase}\e[0m with HTML: \e[34m#{html_content}\e[0m"
      else
        puts "   ㄴ Applying rule \e[31m#{rule_name}\e[0m to node \e[32m#{node.node.name.downcase}\e[0m"
      end
    end
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
