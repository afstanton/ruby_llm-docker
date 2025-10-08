# frozen_string_literal: true

module RubyLLM
  module Docker
    # RubyLLM tool for retrieving Docker container logs.
    #
    # This tool provides access to container logs with flexible filtering and
    # formatting options. It can retrieve both stdout and stderr logs with
    # optional timestamps and tail functionality for recent entries.
    #
    # == Features
    #
    # - Retrieve stdout and/or stderr logs
    # - Optional timestamp inclusion
    # - Tail functionality for recent logs
    # - Flexible log stream selection
    # - Comprehensive error handling
    # - Works with any container state
    #
    # == Log Sources
    #
    # Docker containers can generate logs from multiple sources:
    # - **stdout**: Standard output from container processes
    # - **stderr**: Standard error from container processes
    # - **timestamps**: Docker-generated timestamps for each log line
    #
    # == Security Considerations
    #
    # Container logs may contain sensitive information:
    # - Application secrets and API keys
    # - User data and personal information
    # - Internal system information
    # - Database connection strings
    # - Error messages with stack traces
    #
    # Security recommendations:
    # - Review log content before sharing
    # - Limit access to container logs
    # - Sanitize logs in production environments
    # - Use log rotation to manage log size
    # - Be cautious with log forwarding
    #
    # == Example Usage
    #
    #   # Get all logs
    #   FetchContainerLogs.call(
    #     server_context: context,
    #     id: "web-server"
    #   )
    #
    #   # Get recent logs with timestamps
    #   FetchContainerLogs.call(
    #     server_context: context,
    #     id: "app-container",
    #     tail: 100,
    #     timestamps: true
    #   )
    #
    #   # Get only error logs
    #   FetchContainerLogs.call(
    #     server_context: context,
    #     id: "database",
    #     stdout: false,
    #     stderr: true
    #   )
    #
    # @see ExecContainer
    # @see Docker::Container#logs
    # @since 0.1.0
    class FetchContainerLogs < RubyLLM::Tool
      description 'Fetch Docker container logs'

      param :id, type: :string, desc: 'Container ID or name'
      param :stdout, type: :boolean, desc: 'Include stdout (default: true)', required: false
      param :stderr, type: :boolean, desc: 'Include stderr (default: true)', required: false
      param :tail, type: :integer, desc: 'Number of lines to show from the end of logs (default: all)',
                   required: false
      param :timestamps, type: :boolean, desc: 'Show timestamps (default: false)', required: false

      # Retrieve logs from a Docker container.
      #
      # This method fetches logs from the specified container with configurable
      # options for log sources (stdout/stderr), formatting (timestamps), and
      # quantity (tail). The logs are returned as a text response.
      #
      # @param id [String] container ID (full or short) or container name
      # @param server_context [Object] RubyLLM context (unused but required)
      # @param stdout [Boolean] whether to include stdout logs (default: true)
      # @param stderr [Boolean] whether to include stderr logs (default: true)
      # @param tail [Integer, nil] number of recent lines to return (nil for all)
      # @param timestamps [Boolean] whether to include timestamps (default: false)
      #
      # @return [RubyLLM::Tool::Response] container logs as text
      #
      # @raise [Docker::Error::NotFoundError] if container doesn't exist
      # @raise [StandardError] for other log retrieval failures
      #
      # @example Get all logs
      #   response = FetchContainerLogs.call(
      #     server_context: context,
      #     id: "nginx-server"
      #   )
      #
      # @example Get recent error logs with timestamps
      #   response = tool.execute(
      #     id: "app-container",
      #     stdout: false,
      #     stderr: true,
      #     tail: 50,
      #     timestamps: true
      #   )
      #
      # @see Docker::Container#logs
      def execute(id:, stdout: true, stderr: true, tail: nil, timestamps: false)
        container = ::Docker::Container.get(id)

        options = {
          stdout: stdout,
          stderr: stderr,
          timestamps: timestamps
        }
        options[:tail] = tail if tail

        container.logs(options)
      rescue ::Docker::Error::NotFoundError
        "Container #{id} not found"
      rescue StandardError => e
        "Error fetching logs: #{e.message}"
      end
    end
  end
end
