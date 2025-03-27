require 'open3'

module Foreman
  module Provision
    class Ssh
      # options: {
      #   template: "/path/to/template",
      #   uuid:     "uuid",
      #   key_data: "private-key-content",
      #   password: "string",
      # }
      def initialize(address, username = "root", options = {})
        @username = username
        @address  = address
        @template = options.delete(:template) || raise("must provide a template")
        @uuid     = options.delete(:uuid)     || "#{@address}-#{@username}"
        @options  = options
        @tmp_key_path = create_tmp_key

        check_auth_options
        establish_connection!
      end

      def deploy!
        upload_template

        logger.debug "Executing #{main_command}"

        begin
          stdout, stderr, status = Open3.capture3(*ssh_cmd(main_command))
          logger.debug(stdout) if stdout.presence
          log_stderr(stderr)
        ensure
          cleanup_files
        end

        status.success?
      end

      private

      def log_stderr(stderr)
        return if stderr.empty?

        stderr.split("\n").each { |l| logger.warn l }
      end

      # Attempt to connect to the remote host and run a simple command
      def establish_connection!
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        logger.info "Establishing SSH connection to #{@address}"
        logger.debug first_cmd(mask: true)

        while (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) < Setting[:ssh_timeout].to_i
          _stdout, stderr, status = Open3.capture3(*first_cmd)

          if status.success?
            logger.info "SSH connection successfully established to #{@address}"
            break
          else
            logger.info "SSH connection to #{@address} failed. Retrying in 2 seconds..."
            log_stderr(stderr)
          end

          sleep 2
        end

        unless status.success?
          cleanup_files
          raise "Failed to connect to #{@address} after #{Setting[:ssh_timeout]} seconds"
        end
      end

      def command_prefix
        (@username == "root") ? "" : "sudo "
      end

      # Use the users home to store the provision script since we can't reliably
      # tell if other locations are writeable or executable by the user.
      def main_command
        main_execution = "(chmod 0500 #{remote_script} && #{command_prefix} #{remote_script} ; echo $? >#{remote_script}.status) 2>&1"
        cleanup = "#{command_prefix} rm -f #{remote_script}"

        "#{command_prefix} sh -c '#{main_execution} | tee #{remote_script}.log; #{cleanup}; exit $(cat #{remote_script}.status)'"
      end

      def logger
        Rails.logger
      end

      def upload_template
        logger.debug "Uploading template to remote system '#{@address}'"
        logger.debug scp_cmd(mask: true)

        stdout, stderr, status = Open3.capture3(*scp_cmd)

        logger.debug stdout if stdout.present?
        log_stderr(stderr)

        return if status.success?

        raise Foreman::Exception.new("Failed to upload '#{@template}' to remote system at #{@address}")
      end

      def passwd_cmd(mask: false)
        return [] if @options[:password].empty?

        value = mask ? '*****' : @options[:password]

        [{'SSHPASS' => value }, "sshpass", "-e"]
      end

      def first_cmd(mask: false)
        ssh_master_opts = ["-o ControlMaster=auto", "-o ControlPath=#{socket_file}", "-o ControlPersist=4m"]
        [passwd_cmd(mask: mask), "ssh", (ssh_options + ssh_master_opts), @address, 'pwd'].flatten
      end

      def ssh_cmd(host_command, mask: false)
        [passwd_cmd(mask: mask), "ssh", ssh_options, @address, host_command].flatten
      end

      def scp_cmd(mask: false)
        [passwd_cmd(mask: mask), "scp", ssh_options, @template, "#{@username}@#{@address}:#{@remote_script}"].flatten
      end

      def ssh_options
        opts = []

        opts << "-o User=#{@username}"
        opts << "-o ControlPath=#{socket_file}"
        opts << "-o StrictHostKeychecking=no"
        opts << "-o UserKnownHostsFile=/dev/null"
        opts << "-o ConnectTimeout=4"
        opts << "-o Compression=yes"
        opts << "-o IdentityFile=#{@tmp_key_path}" if @options[:key_data].present?

        methods = []
        methods << 'publickey' if @options[:key_data].present?
        methods << 'password' if @options[:password].present?

        opts << "-o PreferredAuthentications=#{methods.join(',')}"

        opts
      end

      def create_tmp_key
        return if @options[:key_data].empty?

        file = Tempfile.new("ssh-key-#{@uuid}")
        file.write(@options[:key_data])
        file.close
        file.path
      end

      def check_auth_options
        return if @options[:key_data].present? || @options[:password].present?

        raise Foreman::Exception.new("Missing :key_data or :password options, no authentication method available")
      end

      def socket_file
        @socket_file ||= begin
          file = Tempfile.new("ssh-socket-#{@uuid}")
          file.close
          file.path
        end
      end

      def cleanup_files
        files = [socket_file]
        files << @tmp_key_path if @options[:key_data].present?

        `ssh -o ControlPath=#{socket_file} #{@address} -O exit`

        FileUtils.rm_f(files)
      end

      def remote_script
        @remote_script ||= "~/#{File.basename(@template)}"
      end
    end
  end
end
