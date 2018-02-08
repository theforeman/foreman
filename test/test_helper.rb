require 'rubygems'

ENV["RAILS_ENV"] = "test"
require 'minitest/mock'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'factory_bot_rails'
require 'controllers/shared/basic_rest_response_test'
require 'facet_test_helper'
require 'active_support_test_case_helper'
require 'fact_importer_test_helper'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest_4
    with.library :rails
  end
end

# Use our custom test runner, and register a fake plugin to skip a specific test
Foreman::Plugin.register :skip_test do
  tests_to_skip "CustomRunnerTest" => [ "custom runner is working" ]
end

# Turn of Apipie validation for tests
Apipie.configuration.validate = false

# To prevent Postgres' errors "permission denied: "RI_ConstraintTrigger"
if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  ActiveRecord::Migration.execute "SET CONSTRAINTS ALL DEFERRED;"
end

module TestCaseRailsLoggerExtensions
  def before_setup
    super
  ensure
    @_ext_current_buffer = StringIO.new
    @_ext_old_logger = Rails.logger
    @_ext_old_ar_logger = ActiveRecord::Base.logger
    Rails.logger = Foreman::SilencedLogger.new(ActiveSupport::TaggedLogging.new(Logger.new(@_ext_current_buffer)))
    ActiveRecord::Base.logger = Rails.logger
  end

  def after_teardown
    Rails.logger = @_ext_old_logger if @_ext_old_logger
    ActiveRecord::Base.logger = @_ext_old_ar_logger if @_ext_old_ar_logger
    if error?
      @_ext_current_buffer.close_write
      STDOUT << "\n\nRails logs for #{self.name} FAILURE:\n"
      STDOUT << @_ext_current_buffer.string
    end
    super
  ensure
    @_ext_current_buffer.close if @_ext_current_buffer
    @_ext_current_buffer = nil
  end
end

class ActiveSupport::TestCase
  prepend TestCaseRailsLoggerExtensions
end

class ActionView::TestCase
  helper Rails.application.routes.url_helpers
end

::Rails::Engine.subclasses.map(&:instance).each do |engine|
  support_file = "#{engine.root}/test/support/foreman_test_helper_additions.rb"
  require support_file if File.exist?(support_file)
end

class ActionController::TestCase
  include ::BasicRestResponseTest
  setup :setup_set_script_name, :set_api_user, :turn_off_login,
    :disable_webpack, :set_admin

  def set_admin
    User.current = users(:admin)
  end

  def turn_off_login
    SETTINGS[:require_ssl] = false
  end

  def setup_set_script_name
    @request.env["SCRIPT_NAME"] = @controller.config.relative_url_root
  end

  def set_api_user
    return unless self.class.to_s[/api/i]
    set_basic_auth(users(:apiadmin), "secret")
  end

  def reset_api_credentials
    @request.env.delete('HTTP_AUTHORIZATION')
  end

  def set_basic_auth(user, password)
    login = user.is_a?(User) ? user.login : user
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(login, password)
    @request.env['CONTENT_TYPE'] = 'application/json'
    @request.env['HTTP_ACCEPT'] = 'application/json'
  end

  # functional tests will fail if assets are not compiled because page
  # rendering will try to include the webpack assets path which will throw an
  # exception.
  def disable_webpack
    Webpack::Rails::Manifest.stubs(:asset_paths).returns([])
  end
end

def clear_plugins
  @klass = Foreman::Plugin
  @plugins_backup = @klass.registered_plugins
  @klass.clear
end

def restore_plugins
  @klass.clear
  @klass.instance_variable_set('@registered_plugins', @plugins_backup)
end
