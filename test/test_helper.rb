require 'rubygems'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'factory_girl_rails'
require 'controllers/shared/basic_rest_response_test'
require 'facet_test_helper'
require 'active_support_test_case_helper'
require 'foreman_tasks/test_helpers'

ForemanTasks.dynflow.require!
ForemanTasks.dynflow.config.disable_active_record_actions = true

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

class ActionView::TestCase
  helper Rails.application.routes.url_helpers
end

::Rails::Engine.subclasses.map(&:instance).each do |engine|
  support_file = "#{engine.root}/test/support/foreman_test_helper_additions.rb"
  require support_file if File.exist?(support_file)
end

class ActionController::TestCase
  include ::BasicRestResponseTest
  setup :setup_set_script_name, :set_api_user, :turn_off_login, :disable_webpack

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
