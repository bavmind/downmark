# frozen_string_literal: true

require "test_helper"

class TestDownmark < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Downmark::VERSION
  end

  ###

  def test_that_it_converts_basic_page
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_basic_table_with_header
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_basic_table_with_columns
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_basic_table_with_columns_and_no_headers
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_list
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_list_with_nested_list
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_lists
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_numbered_lists
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_headlines
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_links
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  def test_that_it_converts_mixed
    html_content = read_fixture(__method__, "html.html")
    expected_md_content = read_fixture(__method__, "markdown.md")
    actual_md_content = Downmark.new.convert(html_content)

    assert_equal expected_md_content, actual_md_content
  end

  private

  def read_fixture(method, name)
    test = method.to_s.gsub("test_that_it_converts_", "")
    File.read(File.join(__dir__, "fixtures/#{test}/#{name}")).strip
  end
end
