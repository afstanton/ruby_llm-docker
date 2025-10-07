# frozen_string_literal: true

require 'ruby_llm'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem_extension(RubyLLM)

loader.setup

require_relative 'docker/version'

module RubyLlm
  module Docker
    class Error < StandardError; end
    # Your code goes here...
  end
end
