# frozen_string_literal: true

require_relative "lib/downmark/version"

Gem::Specification.new do |spec|
  spec.name = "downmark"
  spec.version = Downmark::VERSION
  spec.authors = ["Devran Cosmo Uenal"]
  spec.email = ["maccosmo@gmail.com"]

  spec.summary = "Downmark is a simple HTML to Markdown converter."
  spec.description = "Downmark is a simple HTML to Markdown converter. It converts HTML to Markdown using Nokogiri."
  spec.homepage = "https://bavmind.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/bavmind"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bavmind/downmark"
  spec.metadata["changelog_uri"] = "https://github.com/bavmind/downmark/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "nokogiri"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
