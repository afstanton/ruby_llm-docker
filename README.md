# RubyLLM Docker Tools

A comprehensive Ruby gem that provides Docker management capabilities through [RubyLLM](https://github.com/afstanton/ruby_llm) tools. This library enables AI assistants and chatbots to interact with Docker containers, images, networks, and volumes programmatically using natural language.

**Note:** This gem is a port of the [DockerMCP](https://github.com/afstanton/docker_mcp) gem, adapted to work directly with RubyLLM tools instead of requiring an external MCP server.

## ⚠️ Security Warning

**This tool is inherently unsafe and should be used with extreme caution.**

- **Arbitrary Code Execution**: The `exec_container` tool allows execution of arbitrary commands inside Docker containers
- **File System Access**: The `copy_to_container` tool can copy files from the host system into containers
- **Container Management**: Full container lifecycle management including creation, modification, and deletion
- **Network & Volume Control**: Complete control over Docker networks and volumes

**Recommendations:**
- Only use in trusted environments
- Ensure proper Docker daemon security configuration
- Consider running with restricted Docker permissions
- Monitor and audit all container operations
- Be cautious when exposing these tools in production environments

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add ruby_llm-docker
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install ruby_llm-docker
```

## Prerequisites

- Docker Engine installed and running
- Ruby 3.2+
- Docker permissions for the user running the application
- RubyLLM gem

## Usage

### Basic Setup

```ruby
require 'ruby_llm/docker'

# Create a new chat instance
chat = RubyLLM::Chat.new(
  api_key: 'your-openai-api-key',
  model: 'gpt-4'
)

# Add all Docker tools to the chat
RubyLLM::Docker.add_all_tools_to_chat(chat)

# Or add individual tools
chat.tools << RubyLLM::Docker::ListContainers.new
chat.tools << RubyLLM::Docker::RunContainer.new
# ... etc
```

### Interactive Command Line Tool

This gem includes a ready-to-use interactive command line tool:

```bash
# Set your OpenAI API key
export OPENAI_API_KEY='your-key-here'

# Run the interactive Docker chat
ruby -r 'ruby_llm/docker' -e "
require_relative 'examples/docker_chat.rb'
DockerChat.new.start
"
```

Or use the included example script:

```bash
ruby examples/docker_chat.rb
```

### Example Usage

Once configured, you can interact with Docker using natural language:

```ruby
# List all containers
response = chat.ask("How many containers are currently running?")

# Create and run a new container
response = chat.ask("Create a new nginx container named 'my-web-server' and expose port 8080")

# Execute commands in a container
response = chat.ask("Check the nginx version in the my-web-server container")

# Copy files to a container
response = chat.ask("Copy my local config.txt file to /etc/nginx/ in the web server container")

# View container logs
response = chat.ask("Show me the logs for the my-web-server container")
```

## 🔨 Available Tools

This gem provides 22 comprehensive Docker management tools organized by functionality:

### Container Management

- **`ListContainers`** - List all Docker containers (running and stopped) with detailed information
- **`CreateContainer`** - Create a new container from an image without starting it
- **`RunContainer`** - Create and immediately start a container from an image
- **`StartContainer`** - Start an existing stopped container
- **`StopContainer`** - Stop a running container gracefully
- **`RemoveContainer`** - Delete a container (must be stopped first unless forced)
- **`RecreateContainer`** - Stop, remove, and recreate a container with the same configuration
- **`ExecContainer`** ⚠️ - Execute arbitrary commands inside a running container
- **`FetchContainerLogs`** - Retrieve stdout/stderr logs from a container
- **`CopyToContainer`** ⚠️ - Copy files or directories from host to container

### Image Management

- **`ListImages`** - List all Docker images available locally
- **`PullImage`** - Download an image from a Docker registry
- **`PushImage`** - Upload an image to a Docker registry
- **`BuildImage`** - Build a new image from a Dockerfile
- **`TagImage`** - Create a new tag for an existing image
- **`RemoveImage`** - Delete an image from local storage

### Network Management

- **`ListNetworks`** - List all Docker networks
- **`CreateNetwork`** - Create a new Docker network
- **`RemoveNetwork`** - Delete a Docker network

### Volume Management

- **`ListVolumes`** - List all Docker volumes
- **`CreateVolume`** - Create a new Docker volume for persistent data
- **`RemoveVolume`** - Delete a Docker volume

### Tool Parameters

Most tools accept standard Docker parameters:
- **Container ID/Name**: Can use either the full container ID, short ID, or container name
- **Image**: Specify images using `name:tag` format (e.g., `nginx:latest`, `ubuntu:22.04`)
- **Ports**: Use Docker port mapping syntax (e.g., `"8080:80"`)
- **Volumes**: Use Docker volume mount syntax (e.g., `"/host/path:/container/path"`)
- **Environment**: Set environment variables as comma-separated `KEY=VALUE` pairs (e.g., `"NODE_ENV=production,PORT=3000"`)

## Common Use Cases

### Development Environment Setup
```ruby
# Ask the AI to set up a development environment
response = chat.ask("Pull the node:18-alpine image and create a development container
  named 'dev-env' with port 3000 exposed and my current directory mounted as /app")

# Install dependencies and start the application
response = chat.ask("Run 'npm install' in the dev-env container")
response = chat.ask("Start the application with 'npm start' in the dev-env container")
```

### Container Debugging
```ruby
# Check container status and debug issues
response = chat.ask("Show me all containers and their current status")
response = chat.ask("Get the logs for the problematic-container")
response = chat.ask("Check the running processes in the problematic-container")
response = chat.ask("Show disk usage in the problematic-container")
```

### File Management
```ruby
# Copy files to containers using natural language
response = chat.ask("Copy my local nginx.conf file to /etc/nginx/ in the web-server container")
response = chat.ask("Copy the entire src directory to /app/ in the app-container")
```

## Error Handling

The tools provide detailed error messages for common issues:

- **Container Not Found**: When referencing non-existent containers
- **Image Not Available**: When trying to use images that aren't pulled locally
- **Permission Denied**: When Docker daemon access is restricted
- **Network Conflicts**: When creating networks with conflicting configurations
- **Volume Mount Issues**: When specified paths don't exist or lack permissions

All errors include descriptive messages to help diagnose and resolve issues.

## Troubleshooting

### Docker Daemon Connection Issues
```bash
# Check if Docker daemon is running
docker info

# Verify Docker permissions
docker ps
```

### Container Operation Failures
- Ensure container IDs/names are correct (ask the AI to list containers)
- Check if containers are in the expected state (running/stopped)
- Verify image availability (ask the AI to list available images)

### Permission Issues
- Ensure the user running the application has Docker permissions
- Consider adding user to the `docker` group: `sudo usermod -aG docker $USER`
- Verify Docker socket permissions: `ls -la /var/run/docker.sock`

## Limitations

- **Platform Specific**: Some container operations may behave differently across operating systems
- **Docker API Version**: Requires compatible Docker Engine API version
- **Resource Limits**: Large file copies and image operations may timeout
- **Concurrent Operations**: Heavy concurrent usage may impact performance

## Contributing

We welcome contributions! Areas for improvement:

- **Enhanced Security**: Additional safety checks and permission validation
- **Better Error Handling**: More specific error messages and recovery suggestions
- **Performance Optimization**: Streaming for large file operations
- **Extended Functionality**: Support for Docker Compose, Swarm, etc.
- **Testing**: Comprehensive test coverage for all tools

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Running Tests
```bash
# Install dependencies
bundle install

# Run the test suite
bundle exec rake spec

# Run tests with coverage
bundle exec rake spec COVERAGE=true
```

### Local Development Setup
```bash
# Clone the repository
git clone https://github.com/afstanton/ruby_llm-docker.git
cd ruby_llm-docker

# Install dependencies
bin/setup

# Start development console
bin/console

# Build the gem locally
bundle exec rake build

# Install locally built gem
bundle exec rake install
```

### Testing with RubyLLM
```bash
# Test the interactive chat tool
export OPENAI_API_KEY='your-key-here'
ruby examples/docker_chat.rb

# Test tool loading without API calls
ruby examples/test_chat.rb
```

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
