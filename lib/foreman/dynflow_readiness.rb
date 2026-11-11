# frozen_string_literal: true

require 'fileutils'

module Foreman
  module DynflowReadiness
    module_function

    def install!(sidekiq:, path:)
      return unless path

      FileUtils.rm_f(path)
      remove_readiness = -> { FileUtils.rm_f(path) }

      sidekiq.on(:startup) do
        FileUtils.mkdir_p(File.dirname(path))
        FileUtils.touch(path)
      end
      sidekiq.on(:quiet, &remove_readiness)
      sidekiq.on(:shutdown, &remove_readiness)
    end
  end
end
