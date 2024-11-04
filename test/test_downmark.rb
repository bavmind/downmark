require "test_helper"

# Preprocess ARGV to adjust the --name parameter
if (idx = ARGV.index("--name"))
  name_arg = ARGV[idx + 1]
  ARGV[idx + 1] = "test_#{name_arg}" unless name_arg.start_with?("test_") || name_arg =~ %r{^/.*/$}
end

class TestDownmark < Minitest::Test
  @failed_tests = []
  @errored_tests = []

  class << self
    attr_reader :failed_tests, :errored_tests
  end

  def test_that_it_has_a_version_number
    refute_nil ::Downmark::VERSION
  rescue Minitest::Assertion => e
    self.class.failed_tests << "test_that_it_has_a_version_number"
    raise e
  rescue StandardError => e
    self.class.errored_tests << "test_that_it_has_a_version_number"
    raise e
  end

  # Dynamic test generation based on fixtures folders
  Dir.glob(File.join(__dir__, "fixtures", "*")).each do |fixture_folder|
    # ignore "__postponed" folder
    next if File.basename(fixture_folder) == "__postponed"

    test_name = File.basename(fixture_folder)

    define_method("test_#{test_name}") do
      html_content = read_fixture(test_name, "html.html")
      expected_md_content = read_fixture(test_name, "markdown.md")
      actual_md_content = Downmark.new.convert(html_content)

      assert_equal expected_md_content, actual_md_content, "Failed on fixture: #{test_name}"
    rescue Minitest::Assertion => e
      self.class.failed_tests << test_name
      raise e # re-raise the error to let Minitest report it as usual
    rescue StandardError => e
      self.class.errored_tests << test_name
      raise e # re-raise the error to let Minitest report it as usual
    end
  end

  Minitest.after_run do
    if failed_tests.any? || errored_tests.any?
      puts "\nTest Results:"
      failed_tests.each do |test|
        puts "\e[31m  ❌ Failure: #{test}\e[0m | Debug: \e[36mruby debug_test.rb --name #{test}\e[0m"
      end
      errored_tests.each do |test|
        puts "\e[31m  💥 Error: #{test}\e[0m | Debug: \e[36mruby debug_test.rb --name #{test}\e[0m"
      end
    else
      puts "\nAll tests passed!"
    end
  end

  private

  def read_fixture(test_name, file_name)
    File.read(File.join(__dir__, "fixtures/#{test_name}/#{file_name}")).strip
  end
end
