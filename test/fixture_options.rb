# frozen_string_literal: true

require "json"
require "nokogiri"

module FixtureOptions
  SOURCE_FIXTURES_PATH = File.expand_path("turndown-test-converter/turndown-tests.html", __dir__)
  FIXTURE_NAME_ALIASES = {
    "fenced-pre" => "fenced pre/code block",
    "pre-code-block-fenced-with-~" => "pre/code block fenced with ~",
    "empty-line-in-start" => "empty line in start/end of code block"
  }.freeze

  def self.for(fixture_name)
    options_by_fixture.fetch(aliased_fixture_name(fixture_name), {})
  end

  def self.options_by_fixture
    @options_by_fixture ||= load_options
  end

  def self.load_options
    return {} unless File.exist?(SOURCE_FIXTURES_PATH)

    doc = Nokogiri::HTML(File.read(SOURCE_FIXTURES_PATH))

    doc.css("div.case[data-options]").each_with_object({}) do |test_case, options|
      fixture_name = slugify(test_case["data-name"])
      parsed_options = JSON.parse(test_case["data-options"])
      options[fixture_name] = deep_transform_keys(parsed_options)
    end
  end

  def self.slugify(test_name)
    test_name.strip.downcase.gsub(/\s+/, "-")
  end

  def self.aliased_fixture_name(fixture_name)
    if FIXTURE_NAME_ALIASES.key?(fixture_name)
      slugify(FIXTURE_NAME_ALIASES[fixture_name])
    else
      fixture_name
    end
  end

  def self.deep_transform_keys(value)
    case value
    when Hash
      value.each_with_object({}) do |(key, nested_value), transformed|
        transformed[camel_to_snake(key).to_sym] = deep_transform_keys(nested_value)
      end
    when Array
      value.map { |item| deep_transform_keys(item) }
    else
      value
    end
  end

  def self.camel_to_snake(key)
    key.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
  end
end
