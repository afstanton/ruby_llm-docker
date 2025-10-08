#!/usr/bin/env ruby

# Example: Using RubyLLM with Docker ListContainers tool
# This script creates a chat with OpenAI and asks about Docker containers

require_relative '../lib/ruby_llm/docker'

# Check if OpenAI API key is configured
unless ENV['OPENAI_API_KEY']
  puts 'Error: Please set OPENAI_API_KEY environment variable'
  puts "Example: export OPENAI_API_KEY='your-api-key-here'"
  exit 1
end

begin
  # Create a new RubyLLM chat instance
  chat = RubyLLM.chat(model: 'gpt-4')

  # Add the ListContainers tool
  chat.with_tool(RubyLLM::Docker::ListContainers)

  # Ask OpenAI how many containers there are
  puts 'Asking OpenAI about Docker containers...'
  response = chat.ask('How many Docker containers are currently on this system?')

  puts "\nOpenAI Response:"
  puts response.content
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
  puts 'This helps us see what needs to be fixed in the ListContainers tool'
end
