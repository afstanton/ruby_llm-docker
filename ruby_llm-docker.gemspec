# frozen_string_literal: true

require_relative 'lib/ruby_llm/docker/version'

Gem::Specification.new do |spec|
  spec.name = 'ruby_llm-docker'
  spec.version = RubyLLM::Docker::VERSION
  spec.authors = ['Aaron F Stanton']
  spec.email = ['afstanton@gmail.com']

  spec.summary = 'Docker management tools for RubyLLM - comprehensive container, image, network, and volume operations'
  spec.description = 'A comprehensive Ruby gem that provides Docker management capabilities through RubyLLM tools. ' \
                     'Enables AI assistants to interact with Docker containers, images, networks, and volumes using ' \
                     'natural language. Ported from DockerMCP to work directly with RubyLLM without requiring an ' \
                     'external MCP server.'
  spec.homepage = 'https://github.com/afstanton/ruby_llm-docker'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency 'base64'
  spec.add_dependency 'docker-api'
  spec.add_dependency 'ruby_llm'
  spec.add_dependency 'zeitwerk'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
