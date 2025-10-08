# frozen_string_literal: true

require 'ruby_llm'
require 'docker'
require 'shellwords'
require 'tool_forge'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem_extension(RubyLLM)
loader.setup

require_relative 'docker/version'

module RubyLLM
  # Docker tools module providing comprehensive Docker management capabilities for RubyLLM.
  #
  # This module contains 22 Docker management tools organized into four categories:
  # - Container Management (10 tools)
  # - Image Management (6 tools)
  # - Network Management (3 tools)
  # - Volume Management (3 tools)
  #
  # @example Basic usage
  #   chat = RubyLLM::Chat.new(api_key: 'your-key', model: 'gpt-4')
  #   RubyLLM::Docker.add_all_tools_to_chat(chat)
  #   response = chat.ask("How many containers are running?")
  module Docker
    class Error < StandardError; end

    # Helper method to get all Docker tool classes
    def self.all_tools
      [
        # Container Management
        ListContainers,
        CreateContainer,
        RunContainer,
        StartContainer,
        StopContainer,
        RemoveContainer,
        RecreateContainer,
        ExecContainer,
        CopyToContainer,
        FetchContainerLogs,

        # Image Management
        ListImages,
        PullImage,
        BuildImage,
        TagImage,
        PushImage,
        RemoveImage,

        # Network Management
        ListNetworks,
        CreateNetwork,
        RemoveNetwork,

        # Volume Management
        ListVolumes,
        CreateVolume,
        RemoveVolume
      ]
    end

    # Helper method to add all Docker tools to a RubyLLM chat instance
    def self.add_all_tools_to_chat(chat)
      all_tools.each do |tool_class|
        chat.with_tool(tool_class)
      end
      chat
    end
  end
end
