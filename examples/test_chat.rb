#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for RubyLLM Docker Tools
# This verifies that all Docker tools load correctly and the chat system works
# without requiring an OpenAI API key or active Docker daemon

require_relative '../lib/ruby_llm/docker'

puts '🧪 Testing Docker Chat functionality...'

# Test 1: Check that all tools are available
puts "\n1. Testing tool loading:"
tools = RubyLLM::Docker.all_tools
puts "✅ Found #{tools.size} Docker tools"
expected_tools = 22
if tools.size == expected_tools
  puts "✅ Expected number of tools loaded (#{expected_tools})"
else
  puts "❌ Expected #{expected_tools} tools, but found #{tools.size}"
  exit 1
end

# Test 2: Check that all tools are valid RubyLLM::Tool classes
puts "\n2. Testing tool validity:"
invalid_tools = tools.reject { |tool| tool < RubyLLM::Tool }
if invalid_tools.empty?
  puts '✅ All tools inherit from RubyLLM::Tool'
else
  puts "❌ Invalid tools found: #{invalid_tools.map(&:name)}"
  exit 1
end

# Test 3: Test helper method (without actually creating a chat)
puts "\n3. Testing helper methods:"
begin
  # Create a mock chat object to test the method exists
  mock_chat = Object.new
  def mock_chat.with_tool(_tool_class)
    self
  end

  result = RubyLLM::Docker.add_all_tools_to_chat(mock_chat)
  if result == mock_chat
    puts '✅ add_all_tools_to_chat method works correctly'
  else
    puts '❌ add_all_tools_to_chat method failed'
    exit 1
  end
rescue StandardError => e
  puts "❌ Helper method test failed: #{e.message}"
  exit 1
end

# Test 4: Check that docker_chat.rb file exists and is executable
puts "\n4. Testing chat script availability:"
chat_script = File.join(__dir__, 'docker_chat.rb')
if File.exist?(chat_script)
  puts '✅ docker_chat.rb exists'

  if File.executable?(chat_script)
    puts '✅ docker_chat.rb is executable'
  else
    puts '⚠️  docker_chat.rb is not executable (run: chmod +x examples/docker_chat.rb)'
  end
else
  puts '❌ docker_chat.rb not found'
  exit 1
end

puts "\n🎉 All tests passed!"
puts "\n📝 Next steps:"
puts "   1. Set your OpenAI API key: export OPENAI_API_KEY='your-key-here'"
puts '   2. Run the chat: ruby examples/docker_chat.rb'
puts '   3. Or run with: ./examples/docker_chat.rb'
puts "\n💡 Example chat commands to try:"
puts "   • 'How many containers are running?'"
puts "   • 'Show me all Docker images'"
puts "   • 'List Docker networks'"
puts "   • '/help' - to see all available tools"
puts "   • '/exit' - to quit the chat"
