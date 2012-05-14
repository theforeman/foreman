require 'foreman/access_permissions'
require 'foreman/default_data/loader'
require 'foreman/default_settings/loader'
require 'foreman/renderer'
require 'foreman/controller'
require 'net'

module Foreman
  # generate a UUID
  def self.uuid
    UUIDTools::UUID.random_create.to_s
  end
end
