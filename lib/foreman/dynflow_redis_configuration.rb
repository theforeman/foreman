# frozen_string_literal: true

require 'openssl'
require 'uri'

module Foreman
  module DynflowRedisConfiguration
    module_function

    def from_env(env = ENV)
      ca_file = env['DYNFLOW_REDIS_SSL_CA_FILE']
      return unless ca_file

      url = env.fetch('DYNFLOW_REDIS_URL')
      raise 'DYNFLOW_REDIS_SSL_CA_FILE requires a rediss URL' unless URI.parse(url).scheme == 'rediss'

      {
        url: url,
        ssl_params: {
          ca_file: ca_file,
          verify_mode: OpenSSL::SSL::VERIFY_PEER,
        },
      }
    end
  end
end
