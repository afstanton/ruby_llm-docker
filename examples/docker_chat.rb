#!/usr/bin/env ruby
# frozen_string_literal: true

# Docker Chat - Interactive command line tool for RubyLLM
# A comprehensive chat interface with all Docker management tools available
# through natural language interaction powered by OpenAI and RubyLLM
#
# Prerequisites:
#   - Set OPENAI_API_KEY environment variable
#   - Docker daemon running and accessible
#
# Usage:
#   export OPENAI_API_KEY='your-key-here'
#   ruby examples/docker_chat.rb
#
# Debug mode:
#   ruby examples/docker_chat.rb --debug        # Enable debug output
#   DOCKER_CHAT_DEBUG=true ruby examples/docker_chat.rb   # Via environment variable
#
# Commands:
#   /exit      - Exit the chat
#   /help      - Show available Docker tools
#   /tools     - List all loaded tools
#   /clear     - Clear the screen
#   /debug     - Toggle debug mode on/off
#   anything else - Send to OpenAI with Docker tools available

require_relative '../lib/ruby_llm/docker'
require 'io/console'

# rubocop:disable Metrics/ClassLength

# Interactive Docker chat interface using RubyLLM and OpenAI.
# Provides natural language interaction with Docker containers, images, networks, and volumes.
class DockerChat
  def initialize
    check_environment
    configure_ruby_llm
    setup_debug_mode
    setup_chat
    @running = true
  end

  def start
    show_welcome
    main_loop
    show_goodbye
  end

  private

  def check_environment
    return if ENV['OPENAI_API_KEY']

    puts '❌ Error: Please set OPENAI_API_KEY environment variable'
    puts "Example: export OPENAI_API_KEY='your-api-key-here'"
    exit 1
  end

  def configure_ruby_llm
    RubyLLM.configure do |config|
      config.openai_api_key = ENV.fetch('OPENAI_API_KEY', nil)
    end
  end

  def setup_debug_mode
    # Check for debug mode via environment variable or command line argument
    @debug_mode = ENV['DOCKER_CHAT_DEBUG'] == 'true' || ARGV.include?('--debug') || ARGV.include?('-d')
    debug_puts '🐛 Debug mode enabled' if @debug_mode
  end

  def debug_puts(message)
    puts message if @debug_mode
  end

  def setup_chat
    # rubocop:disable Layout/BlockAlignment
    # rubocop:disable Style/MultilineBlockChain
    @chat = RubyLLM.chat(model: 'gpt-4')
                   .on_tool_call do |tool_call|
                      debug_puts "🔧 Calling tool: #{tool_call.name}"
                      debug_puts "📝 Arguments: #{tool_call.arguments}"
                    end
                    .on_tool_result do |result|
                      debug_puts "✅ Tool returned: #{result}"
                    end
    # rubocop:enable Layout/BlockAlignment
    # rubocop:enable Style/MultilineBlockChain

    # Add all Docker tools to the chat
    RubyLLM::Docker.add_all_tools_to_chat(@chat)

    puts '🔧 Loading Docker tools...'
    puts "✅ Loaded #{RubyLLM::Docker.all_tools.size} Docker tools"
  end

  def show_welcome
    puts "\n#{'=' * 60}"
    puts '🐳 Welcome to Docker Chat!'
    puts '   Interactive CLI with all Docker tools available'
    puts '=' * 60
    puts
    puts '💡 You can ask questions about Docker containers, images, networks, and volumes.'
    puts '   OpenAI has access to all Docker management tools on this system.'
    puts
    puts 'Commands:'
    puts '  /exit  - Exit the chat'
    puts '  /help  - Show available Docker tools'
    puts '  /tools - List all loaded tools'
    puts '  /clear - Clear the screen'
    puts '  /debug - Toggle debug mode on/off'
    puts
    puts '🚀 Ready! Type your questions or commands...'
    puts
    debug_puts '🐛 Debug mode is currently enabled. Use /debug to toggle.'
  end

  def main_loop
    while @running
      print "\n🐳 > "

      begin
        input = gets&.chomp

        # Handle Ctrl+C or EOF
        if input.nil?
          @running = false
          break
        end

        process_input(input.strip)
      rescue Interrupt
        puts "\n\n👋 Received interrupt signal. Use /exit to quit cleanly."
      rescue StandardError => e
        puts "❌ Error: #{e.message}"
        puts '   Please try again or type /exit to quit.'
      end
    end
  end

  def process_input(input)
    return if input.empty?

    case input.downcase
    when '/exit', '/quit', '/q'
      @running = false
    when '/help', '/h'
      show_help
    when '/tools', '/t'
      show_tools
    when '/clear', '/c'
      clear_screen
    when '/debug', '/d'
      toggle_debug_mode
    when input.start_with?('/')
      puts "❓ Unknown command: #{input}"
      puts '   Type /help for available commands'
    else
      handle_chat_message(input)
    end
  end

  def handle_chat_message(message)
    puts "\n🤔 Thinking..."

    begin
      response = @chat.ask(message)

      puts "\n🤖 OpenAI Response:"
      puts '─' * 50
      puts response.content
      puts '─' * 50
    rescue StandardError => e
      puts "\n❌ Error communicating with OpenAI:"
      puts "   #{e.class}: #{e.message}"
      puts '   Please check your API key and network connection.'
    end
  end

  def show_help
    puts "\n📚 Available Docker Tools:"
    puts '─' * 50

    tools_by_category = {
      'Container Management' => [
        'ListContainers - List all Docker containers',
        'CreateContainer - Create new containers',
        'RunContainer - Create and start containers',
        'StartContainer - Start stopped containers',
        'StopContainer - Stop running containers',
        'RemoveContainer - Delete containers',
        'RecreateContainer - Recreate containers with same config',
        'ExecContainer - Execute commands inside containers',
        'CopyToContainer - Copy files to containers',
        'FetchContainerLogs - Get container logs'
      ],
      'Image Management' => [
        'ListImages - List available Docker images',
        'PullImage - Download images from registries',
        'BuildImage - Build images from Dockerfile',
        'TagImage - Tag images with new names',
        'PushImage - Upload images to registries',
        'RemoveImage - Delete images'
      ],
      'Network Management' => [
        'ListNetworks - List Docker networks',
        'CreateNetwork - Create custom networks',
        'RemoveNetwork - Delete networks'
      ],
      'Volume Management' => [
        'ListVolumes - List Docker volumes',
        'CreateVolume - Create persistent volumes',
        'RemoveVolume - Delete volumes'
      ]
    }

    tools_by_category.each do |category, tools|
      puts "\n#{category}:"
      tools.each { |tool| puts "  • #{tool}" }
    end

    puts "\n💡 Example questions you can ask:"
    puts "  • 'How many containers are running?'"
    puts "  • 'Show me all Docker images'"
    puts "  • 'Create a new nginx container named web-server'"
    puts "  • 'What networks are available?'"
    puts "  • 'Pull the latest Ubuntu image'"
  end

  def show_tools
    puts "\n🔧 Loaded Tools (#{RubyLLM::Docker.all_tools.size}):"
    puts '─' * 30

    RubyLLM::Docker.all_tools.each_with_index do |tool_class, index|
      tool_name = tool_class.name.split('::').last
      puts "#{(index + 1).to_s.rjust(2)}. #{tool_name}"
    end
  end

  def clear_screen
    system('clear') || system('cls')
    puts '🐳 Docker Chat - Screen cleared'
  end

  def toggle_debug_mode
    @debug_mode = !@debug_mode
    status = @debug_mode ? 'enabled' : 'disabled'
    puts "🐛 Debug mode #{status}"
    debug_puts 'Debug output will now be shown for tool calls and results' if @debug_mode
  end

  def show_goodbye
    puts "\n👋 Thanks for using Docker Chat!"
    puts '   Hope you found it helpful for managing your Docker environment.'
    puts
  end
end
# rubocop:enable Metrics/ClassLength

# Start the chat if this file is run directly
if __FILE__ == $PROGRAM_NAME
  begin
    DockerChat.new.start
  rescue StandardError => e
    puts "\n💥 Fatal error: #{e.class} - #{e.message}"
    puts '   Please check your setup and try again.'
    exit 1
  end
end
