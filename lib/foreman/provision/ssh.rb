require 'fog'
require 'timeout'

class Foreman::Provision::SSH
  attr_reader :template, :uuid, :results, :address, :username, :options

  def initialize address, username = "root", options = { }
    @username = username
    @address  = address
    @template = options.delete(:template) || raise("must provide a template")
    @uuid     = options.delete(:uuid)     || "#{address}-#{username}"
    @options  = defaults.merge(options)

    initiate_connection!
  end

  def deploy!
    logger.debug "about to upload #{template} to remote system at #{remote_script}"
    scp.upload(template, remote_script)
    logger.debug "about to execute #{command}"
    @results = ssh.run(command)
    log_stdout
    log_stderr
    success?
  end

  private

  def success?
    return true if results.empty?
    results.map(&:status).compact == [0]
  end

  def log_stdout
    results.each do |r|
      r.stdout.split("\n").each { |l| logger.debug l }
    end
  end

  def log_stderr
    results.each do |r|
      r.stderr.split("\n").each { |l| logger.warn l }
    end
  end

  def remote_script
    File.join("/", "tmp", "bootstrap-#{uuid}")
  end

  def command_prefix
    username == "root" ? "" : "sudo "
  end

  def command
    "#{command_prefix} bash -c 'chmod 0701 #{remote_script} && #{command_prefix} #{remote_script}' | tee #{remote_script}.log"
  end

  def defaults
    {
      :keys_only    => true,
      :config       => false,
      :auth_methods => %w( publickey ),
      :compression  => "zlib",
      :logger       => logger,
    }
  end

  def logger
    Rails.logger
  end

  def initiate_connection!
    Timeout::timeout(360) do
      begin
        Timeout::timeout(8) do
          ssh.run('pwd')
        end
      rescue Errno::ECONNREFUSED
        logger.debug "Connection refused for #{address}, retrying"
        sleep(2)
        retry
      rescue Errno::EHOSTUNREACH
        logger.debug "Host unreachable for #{address}, retrying"
        sleep(2)
        retry
      rescue Timeout::Error
        retry
      rescue => e
        logger.debug "SSH error: #{e.message}\n " + e.backtrace.join("\n ")
      end
    end
  end

  def ssh
    Fog::SSH.new(address, username, options.merge(:timeout => 4))
  end

  def scp
    Fog::SCP.new(address, username, options)
  end

end
