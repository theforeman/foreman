require 'foreman/access_permissions'
require 'foreman/default_data/loader'
require 'foreman/default_settings/loader'
require 'foreman/renderer'
require 'foreman/controller'
require 'net'

module Foreman
  mattr_accessor :report_logger, :fact_logger, :default_logger
end
