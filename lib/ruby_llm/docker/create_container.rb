# frozen_string_literal: true

module RubyLLM
  module Docker
    # RubyLLM tool for creating Docker containers without starting them.
    #
    # This tool provides the ability to create Docker containers from images with
    # comprehensive configuration options. Unlike RunContainer, this tool only
    # creates the container but does not start it, allowing for additional
    # configuration or manual startup control.
    #
    # == Features
    #
    # - Create containers from any available Docker image
    # - Full container configuration support
    # - Port exposure and binding configuration
    # - Volume mounting capabilities
    # - Environment variable configuration
    # - Custom command specification
    # - Comprehensive error handling with specific error types
    #
    # == Security Considerations
    #
    # - Containers inherit Docker daemon security context
    # - Host configuration can expose host resources
    # - Volume mounts provide filesystem access
    # - Port bindings expose services to networks
    # - Environment variables may contain sensitive data
    #
    # Use appropriate security measures:
    # - Validate image sources and integrity
    # - Limit host resource exposure
    # - Use read-only volumes where appropriate
    # - Restrict network access through host configuration
    # - Sanitize environment variables
    #
    # == Example Usage
    #
    #   # Simple container creation
    #   CreateContainer.call(
    #     server_context: context,
    #     image: "nginx:latest",
    #     name: "web-server"
    #   )
    #
    #   # Advanced container with configuration
    #   CreateContainer.call(
    #     server_context: context,
    #     image: "postgres:13",
    #     name: "database",
    #     env: "POSTGRES_PASSWORD=secret,POSTGRES_DB=myapp",
    #     exposed_ports: {"5432/tcp" => {}},
    #     host_config: {
    #       "PortBindings" => {"5432/tcp" => [{"HostPort" => "5432"}]},
    #       "Binds" => ["/host/data:/var/lib/postgresql/data:rw"]
    #     }
    #   )
    #
    # @see RunContainer
    # @see StartContainer
    # @see Docker::Container.create
    # @since 0.1.0
    class CreateContainer < RubyLLM::Tool
      description 'Create a Docker container'

      param :image, desc: 'Image name to use (e.g., "ubuntu:22.04")'
      param :name, desc: 'Container name (optional)', required: false
      param :cmd, desc: 'Command to run (optional)', required: false
      param :env,
            desc: 'Environment variables as comma-separated KEY=VALUE pairs (optional, e.g., "VAR1=value1,VAR2=value2")', required: false
      param :exposed_ports, desc: 'Exposed ports as JSON object (optional)', required: false
      param :host_config, desc: 'Host configuration including port bindings, volumes, etc. as JSON object (optional)',
                          required: false

      # Create a new Docker container from an image.
      #
      # This method creates a container with the specified configuration but does
      # not start it. The container can be started later using StartContainer or
      # other Docker commands. All configuration parameters are optional except
      # for the base image.
      #
      # @param image [String] Docker image name with optional tag (e.g., "nginx:latest")
      # @param server_context [Object] RubyLLM context (unused but required)
      # @param name [String, nil] custom name for the container
      # @param cmd [String, nil] command to execute in the container
      # @param env [String, nil] environment variables as comma-separated KEY=VALUE pairs
      # @param exposed_ports [Hash, nil] ports to expose in {"port/protocol" => {}} format
      # @param host_config [Hash, nil] Docker host configuration including bindings and volumes
      #
      # @return [RubyLLM::Tool::Response] creation results with container ID and name
      #
      # @raise [Docker::Error::NotFoundError] if the specified image doesn't exist
      # @raise [Docker::Error::ConflictError] if container name already exists
      # @raise [StandardError] for other creation failures
      #
      # @example Create simple container
      #   response = CreateContainer.call(
      #     server_context: context,
      #     image: "alpine:latest",
      #     name: "test-container"
      #   )
      #
      # @example Create container with full configuration
      #   response = CreateContainer.call(
      #     server_context: context,
      #     image: "redis:7-alpine",
      #     name: "redis-cache",
      #     env: "REDIS_PASSWORD=secret",
      #     exposed_ports: {"6379/tcp" => {}},
      #     host_config: {
      #       "PortBindings" => {"6379/tcp" => [{"HostPort" => "6379"}]},
      #       "RestartPolicy" => {"Name" => "unless-stopped"}
      #     }
      #   )
      #
      # @see Docker::Container.create
      def execute(image:, name: nil, cmd: nil, env: nil, exposed_ports: nil, host_config: nil)
        config = { 'Image' => image }
        config['name'] = name if name
        config['Cmd'] = cmd if cmd

        # Parse environment variables string into array if provided
        if env && !env.empty?
          env_array = env.split(',').map(&:strip).select { |e| e.include?('=') }
          config['Env'] = env_array unless env_array.empty?
        end

        config['ExposedPorts'] = exposed_ports if exposed_ports
        config['HostConfig'] = host_config if host_config

        container = ::Docker::Container.create(config)
        container_name = container.info['Names']&.first&.delete_prefix('/')

        "Container created successfully. ID: #{container.id}, Name: #{container_name}"
      rescue ::Docker::Error::NotFoundError
        "Image #{image} not found"
      rescue ::Docker::Error::ConflictError
        "Container with name #{name} already exists"
      rescue StandardError => e
        "Error creating container: #{e.message}"
      end
    end
  end
end
