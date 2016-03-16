require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # Remove previous test log to speed tests up
  # Comment out these lines to enable test logging
  test_log = File.expand_path('../../log/test.log', __FILE__)
  FileUtils.rm(test_log) if File.exist?(test_log)

  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require 'mocha/mini_test'
  require 'factory_girl_rails'
  require 'functional/shared/basic_rest_response_test'
  require 'facet_test_helper'
  require 'active_support_test_case_helper'

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
end

Spork.each_run do
  # This code will be run each time you run your specs.
  class ActionController::TestCase
    include ::BasicRestResponseTest
    setup :setup_set_script_name, :set_api_user, :turn_of_login

    def turn_of_login
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
  end
end
