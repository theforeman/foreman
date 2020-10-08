# frozen_string_literal: true

require 'open3'

module Foreman
  class CommandRunner
    attr_accessor :command, :stdin, :stdout, :stderr, :status

    def initialize(command_and_args, stdin)
      @stdin = stdin
      @command = command_and_args
      # security checks: ensure no shell, absolute path, permissions and executable
      raise(::Foreman::Exception.new(N_("Command must be array: %s"), command)) unless command.kind_of?(Array)
      raise(::Foreman::Exception.new(N_("At least one command must be specified"))) if command.empty?
      raise(::Foreman::Exception.new(N_("Absolute command path must be specified: %s"), bin)) unless Pathname.new(bin).absolute?
      raise(::Foreman::Exception.new(N_("Command %s not found or unreadable"), bin)) unless File.exist?(bin)
      raise(::Foreman::Exception.new(N_("Command %s not executable"), bin)) unless File.executable?(bin)
    end

    def run!
      Rails.logger.debug { "Running command: #{command.inspect}" }
      @stdout, @stderr, @status = capture3(command, stdin)
      Rails.logger.debug { "Command #{bin} returned #{status}, enable blob logger to see more" }
      Foreman::Logging.blob("Command #{bin} STDOUT", stdout)
      unless status.success?
        Rails.logger.error "Command #{bin} STDERR:"
        Rails.logger.error stderr
        raise(::Foreman::Exception.new(N_("Command %{cmd} returned %{status}"), cmd: command, status: status))
      end
      stdout
    end

    private

    def capture3(cmd, indata)
      Open3.capture3(*cmd, stdin_data: indata)
    end

    def bin
      command&.first
    end
  end
end
