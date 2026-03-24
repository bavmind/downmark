# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "downmark"
require_relative "fixture_options"

require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use!
