require "nokogiri"
require "fileutils"

# Read the HTML file
file_content = File.read("turndown-tests.html")

# Parse the HTML content
doc = Nokogiri::HTML(file_content)

puts "Converting Turndown tests to Markdown..."

# Loop through each test case
doc.css("div.case").each do |test_case|
  # Extract the test name and format it
  test_name = test_case["data-name"]
  test_name_slug = test_name.strip.downcase.gsub(/\s+/, "-")

  # Extract the input content
  input_element = test_case.at_css("div.input")
  input_content = input_element.inner_html.strip

  # Extract the expected content
  expected_element = test_case.at_css("pre.expected")
  expected_content = expected_element.text.strip

  # Create the directory for the test case
  dir_path = File.join("..", "fixtures", test_name_slug)
  FileUtils.mkdir_p(dir_path)
  puts "Creating directory: #{dir_path}"

  # Prepare the HTML file content
  html_file_content = <<~HTML
    <!DOCTYPE html>
    <html>
      <head>
      </head>
      <body>
        #{input_content}
      </body>
    </html>
  HTML

  # Write the html.html file
  File.write(File.join(dir_path, "html.html"), html_file_content)

  # Write the markdown.md file
  File.write(File.join(dir_path, "markdown.md"), expected_content)
end
