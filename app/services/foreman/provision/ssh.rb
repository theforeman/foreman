require 'open3'

module Foreman
  module Provision
    # Simple SSH client implemented via OpenSSH ssh and sshpass commands.
    class Ssh
      def initialize(address, username = "root", options = {})
        @username = username
        @address  = address
        @template = options.delete(:template) || (raise ::Foreman::Exception.new(N_('must provide a template')))
        @uuid     = options.delete(:uuid) || "#{@address}-#{@username}"
        @options  = options

        check_auth_options
      end

      def deploy!
        logger.info "Executing provisioning script on #{@address}"

        _stdout, _stderr, status = run_ssh(
          "#{command_prefix}sh",
          stdin_data: File.binread(@template)
        )

        status.success?
      end

      # Wait for maximum of ssh_timeout setting for a client to complete full connection.
      def ping
        deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + Setting[:ssh_timeout].to_i

        logger.info "Making a ping SSH connection to #{@address}"

        loop do
          _stdout, _stderr, status = run_ssh("true")

          if status.success?
            return self
          end

          if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
            raise ::Foreman::Exception.new(
              N_("Failed to connect to %{address} after %{timeout} seconds"),
              {:address => @address, :timeout => Setting[:ssh_timeout]}
            )
          end

          logger.debug "SSH connection to #{@address} failed, retrying..."
          sleep 2
        end
      end

      private

      def run_ssh(remote_command, stdin_data: nil)
        with_tmp_key do |key_file|
          cmd = build_command(remote_command, key_file)
          opts = {}
          opts[:stdin_data] = stdin_data if stdin_data
          stdout, stderr, status = Open3.capture3(*cmd, **opts)
          logger.debug(stdout) if stdout.present?
          stderr.each_line { |l| logger.warn(l.chomp) } if stderr.present?
          [stdout, stderr, status]
        end
      end

      def build_command(remote_command, key_file)
        cmd = []
        if @options[:password].present?
          cmd.push({"SSHPASS" => @options[:password]}, "sshpass", "-e")
        end
        cmd.push("ssh", *ssh_options(key_file), "#{@username}@#{@address}", remote_command)
        cmd
      end

      def ssh_options(key_file)
        opts = %w[
          -oStrictHostKeyChecking=no
          -oUserKnownHostsFile=/dev/null
          -oConnectTimeout=4
          -oCompression=yes
          -oBatchMode=yes
        ]

        opts.push("-oIdentityFile=#{key_file.path}") if key_file

        methods = []
        methods << "publickey" if @options[:key_data].present?
        methods << "password" if @options[:password].present?
        opts.push("-oPreferredAuthentications=#{methods.join(',')}")

        opts
      end

      def command_prefix
        @username == "root" ? "" : "sudo "
      end

      def with_tmp_key
        return yield(nil) if @options[:key_data].blank?

        Tempfile.create("foreman-ssh-#{@uuid}") do |f|
          f.write(@options[:key_data])
          yield f
        end
      end

      def check_auth_options
        return if @options[:key_data].present? || @options[:password].present?

        raise Foreman::Exception.new(
          N_("Missing SSH credentials: provide key_data or password")
        )
      end

      def logger
        Rails.logger
      end
    end
  end
end
