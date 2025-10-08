# frozen_string_literal: true

module RubyLLM
  module Docker
    # RubyLLM tool for removing Docker containers.
    #
    # This tool provides the ability to permanently delete Docker containers
    # from the system. It supports both graceful removal of stopped containers
    # and forced removal of running containers. Optionally, it can also remove
    # associated anonymous volumes.
    #
    # == Features
    #
    # - Remove stopped containers safely
    # - Force removal of running containers
    # - Optional removal of associated volumes
    # - Comprehensive error handling
    # - Works with containers by ID or name
    #
    # == Data Loss Warning
    #
    # ⚠️ **DESTRUCTIVE OPERATION** ⚠️
    #
    # This operation permanently deletes containers and potentially data:
    # - Container filesystem changes are lost forever
    # - Running processes are killed immediately (with force)
    # - Associated volumes may be removed if specified
    # - Container logs and metadata are deleted
    # - Operation cannot be undone
    #
    # == Security Considerations
    #
    # - Forced removal can cause data corruption
    # - Volume removal may affect other containers
    # - Running container removal terminates services abruptly
    # - Sensitive data in container memory is not securely wiped
    #
    # Best practices:
    # - Stop containers gracefully before removal
    # - Backup important data before removing
    # - Verify volume dependencies before volume removal
    # - Use force removal only when necessary
    #
    # == Example Usage
    #
    #   # Remove stopped container
    #   RemoveContainer.call(
    #     server_context: context,
    #     id: "old-container"
    #   )
    #
    #   # Force remove running container with volumes
    #   RemoveContainer.call(
    #     server_context: context,
    #     id: "problematic-container",
    #     force: true,
    #     volumes: true
    #   )
    #
    # @see StopContainer
    # @see CreateContainer
    # @see Docker::Container#delete
    # @since 0.1.0
    class RemoveContainer < RubyLLM::Tool
      description 'Remove a Docker container'

      param :id, desc: 'Container ID or name'
      param :force, type: :boolean, desc: 'Force removal of running container (default: false)', required: false
      param :volumes, type: :boolean, desc: 'Remove associated volumes (default: false)', required: false

      # Remove a Docker container permanently.
      #
      # This method deletes a container from the Docker system. By default,
      # it only removes stopped containers. The force option allows removal
      # of running containers, and the volumes option removes associated
      # anonymous volumes.
      #
      # @param id [String] container ID (full or short) or container name
      # @param server_context [Object] RubyLLM context (unused but required)
      # @param force [Boolean] whether to force remove running containers (default: false)
      # @param volumes [Boolean] whether to remove associated volumes (default: false)
      #
      # @return [RubyLLM::Tool::Response] removal operation results
      #
      # @raise [Docker::Error::NotFoundError] if container doesn't exist
      # @raise [StandardError] for other removal failures
      #
      # @example Remove stopped container
      #   response = RemoveContainer.call(
      #     server_context: context,
      #     id: "finished-job"
      #   )
      #
      # @example Force remove running container
      #   response = RemoveContainer.call(
      #     server_context: context,
      #     id: "stuck-container",
      #     force: true
      #   )
      #
      # @example Remove container and its volumes
      #   response = tool.execute(
      #     id: "temp-container",
      #     volumes: true
      #   )
      #
      # @see Docker::Container#delete
      def execute(id:, force: false, volumes: false)
        container = ::Docker::Container.get(id)
        container.delete(force: force, v: volumes)

        "Container #{id} removed successfully"
      rescue ::Docker::Error::NotFoundError
        "Container #{id} not found"
      rescue StandardError => e
        "Error removing container: #{e.message}"
      end
    end
  end
end
