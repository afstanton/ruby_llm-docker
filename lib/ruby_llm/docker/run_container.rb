# frozen_string_literal: true

module RubyLLM
  module Docker
    # RubyLLM tool for running Docker containers (create and start in one operation).
    #
    # This tool provides a convenient way to create and immediately start Docker
    # containers from images. It combines the functionality of container creation
    # and startup into a single operation, which is the most common use case for
    # Docker containers.
    #
    # == Features
    #
    # - Create and start containers in one operation
    # - Full support for container configuration options
    # - Port mapping and network configuration
    # - Volume mounting capabilities
    # - Environment variable configuration
    # - Custom command execution
    # - Comprehensive error handling
    #
    # == Security Considerations
    #
    # - Containers inherit Docker daemon privileges
    # - Port mappings expose services to host network
    # - Volume mounts provide filesystem access
    # - Environment variables may contain sensitive data
    # - Custom commands can execute arbitrary code
    #
    # Use appropriate security measures:
    # - Run containers with minimal required privileges
    # - Limit port exposure to necessary services only
    # - Use read-only volumes where possible
    # - Avoid mounting sensitive host directories
    # - Validate environment variables for secrets
    #
    # == Example Usage
    #
    #   # Simple container run
    #   RunContainer.call(
    #     server_context: context,
    #     image: "nginx:latest",
    #     name: "web-server"
    #   )
    #
    #   # Advanced configuration with ports and volumes
    #   RunContainer.call(
    #     server_context: context,
    #     image: "postgres:13",
    #     name: "database",
    #     env: ["POSTGRES_PASSWORD=secret"],
    #     host_config: {
    #       "PortBindings" => {"5432/tcp" => [{"HostPort" => "5432"}]},
    #       "Binds" => ["/host/data:/var/lib/postgresql/data"]
    #     }
    #   )
    #
    # @see CreateContainer
    # @see StartContainer
    # @see Docker::Container.create
    # @since 0.1.0
    class RunContainer < RubyLLM::Tool
      description 'Run a Docker container (create and start)'

      param :image, desc: 'Image name to use (e.g., "ubuntu:22.04")'
      param :name, desc: 'Container name (optional)', required: false
      param :cmd, desc: 'Command to run (optional)', required: false
      param :env,
            desc: 'Environment variables as comma-separated KEY=VALUE pairs (optional, e.g., "VAR1=value1,VAR2=value2")', required: false
      param :exposed_ports, desc: 'Exposed ports as JSON object (optional)', required: false
      param :host_config, desc: 'Host configuration including port bindings, volumes, etc.',
                          required: false

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
        container.start
        container_name = container.info['Names']&.first&.delete_prefix('/')

        "Container started successfully. ID: #{container.id}, Name: #{container_name}"
      rescue ::Docker::Error::NotFoundError
        "Image #{image} not found"
      rescue ::Docker::Error::ConflictError
        "Container with name #{name} already exists"
      rescue StandardError => e
        "Error running container: #{e.message}"
      end
    end
  end
end
