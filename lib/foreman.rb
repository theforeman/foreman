require 'foreman/access_permissions'
require 'foreman/default_data/loader'
require 'foreman/renderer'
require 'foreman/controller'
require 'net'
require 'foreman/provision' if SETTINGS[:unattended]
require 'audit_extensions'

module Foreman
  # generate a UUID
  def self.uuid
    UUIDTools::UUID.random_create.to_s
  end
end
