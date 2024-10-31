$LOAD_PATH.unshift File.expand_path("./lib", __dir__)
require "downmark"

# Check if the name option is provided
if ARGV.length != 2 || ARGV[0] != "--name"
  puts "Usage: ruby debug_test.rb --name <test_name>"
  exit
end

test_name = ARGV[1]

# Construct the HTML file path based on the provided name
html_file_path = File.expand_path("test/fixtures/#{test_name}/html.html", __dir__)

# Check if the file exists
unless File.exist?(html_file_path)
  puts "Error: File not found - #{html_file_path}"
  exit
end

# Read the HTML content from the file
html_content = File.read(html_file_path)

# Convert the HTML content to Markdown
system("ruby", "-Ilib:test", "test/test_downmark.rb", "--name", test_name)
puts "--------------------------------------------------"
puts "Output:"
downmark = Downmark.new(debug: true)
markdown_content = downmark.convert(html_content)
puts markdown_content
