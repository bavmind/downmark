# frozen_string_literal: true

require "nokogiri"

require_relative "downmark/version"

# Documentation

# Downmark
class Downmark
  def initialize(html, options = {})
    @html = html
    @options = options
  end

  def convert
    html_to_markdown(Nokogiri::HTML(@html)).strip
  end

  def html_to_markdown(node)
    markdown = ""

    node.children.each.with_index do |child, _index|
      case child.name
      when "a"
        markdown += "[#{child.text.strip}](#{child["href"]})" if child["href"]
      when "br"
        markdown += "\n"
      when "div", "article", "p", "body", "html", "main", "form"
        markdown += "#{html_to_markdown(child).strip}\n\n"
      when "span", "u"
        markdown += " #{html_to_markdown(child).strip} "
      when "li"
        if child.parent.name == "ol"
          value = child["value"].nil? ? child.parent.css("li").index(child) + 1 : child["value"]
          markdown += "#{value}. #{html_to_markdown(child).strip}\n"
        elsif child.parent.name == "ul"
          markdown += "* #{html_to_markdown(child).strip}\n"
        end
      when "ul"
        markdown += "#{html_to_markdown(child).strip}\n"
        markdown += "\n\n"
      when "ol"
        child.css("li").each_with_index do |li, index|
          value = li["value"].nil? ? index + 1 : li["value"]
          markdown += "#{value}. #{li.text.strip}\n"
        end
        markdown += "\n\n"
      when "table"
        child.css("tr").each_with_index do |row, index|
          # check if we want to skip the header
          skip_header = !@options[:skip_header].nil? && @options[:skip_header] == true
          if skip_header && index.zero?
            markdown += "#{"| - " * row.css("th, td").size}|\n"
            markdown += "#{"| --- " * row.css("th, td").size}|\n"
          end

          markdown += "| #{row.css("th, td").map { |cell| cell.text.strip }.join(" | ")} |\n"
          markdown += "#{"| --- " * row.css("th, td").size}|\n" if !skip_header && index.zero?
        end
        markdown += "\n\n"
      when "h1"
        markdown += "# #{child.text.strip}\n\n"
      when "h2"
        markdown += "## #{child.text.strip}\n\n"
      when "h3"
        markdown += "### #{child.text.strip}\n\n"
      when "h4"
        markdown += "#### #{child.text.strip}\n\n"
      when "h5"
        markdown += "##### #{child.text.strip}\n\n"
      when "h6"
        markdown += "###### #{child.text.strip}\n\n"
      when "em"
        markdown += " _#{child.text.strip}_ "
      when "strong"
        markdown += " **#{child.text.strip}** "
      when "text"
        markdown += child.text.strip
      else
        markdown += ""
      end
    end

    markdown
  end
end
