require 'rubygems'
require 'spork'
# $LOAD_PATH required for testdrb party of spork-minitest
$LOAD_PATH << "test"

unless RUBY_VERSION =~ /^1\.8/
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_group 'API', 'app/controllers/api'
  end
end

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require "minitest/autorun"
  require 'capybara/rails'

  # Turn of Apipie validation for tests
  Apipie.configuration.validate = false

  class ActiveSupport::TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting

    fixtures :all
    set_fixture_class({ :hosts => Host::Base })

    # for backwards compatibility to between Minitest syntax
    alias_method :assert_not,       :refute
    alias_method :assert_no_match,  :refute_match
    alias_method :assert_not_nil,   :refute_nil
    alias_method :assert_not_equal, :refute_equal
    alias_method :assert_raise,     :assert_raises
    class <<self
      alias_method :test,  :it
    end

    # Add more helper methods to be used by all tests here...
    def logger
      Rails.logger
    end

    class MiniTest::Unit::TestCase
      include RR::Adapters::MiniTest
    end

    def set_session_user
      SETTINGS[:login] ? {:user => User.admin.id, :expires_at => 5.minutes.from_now} : {}
    end

    def as_user user
      saved_user   = User.current
      User.current = users(user)
      result = yield
      User.current = saved_user
      result
    end

    def as_admin &block
      as_user :admin, &block
    end

    def setup_users
      User.current = users(:admin)
      user = users(:one)
      @request.session[:user] = user.id
      @request.session[:expires_at] = 5.minutes.from_now
      user.update_attributes!(:roles => [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')])
    end

    def setup_user operation, type=""
      @one = users(:one)
      as_admin do
        role = Role.find_or_create_by_name :name => "#{operation}_#{type}"
        role.permissions = ["#{operation}_#{type}".to_sym]
        @one.roles = [role]
        @one.save!
      end
      User.current = @one
    end

    def unattended?
      SETTINGS[:unattended].nil? or SETTINGS[:unattended]
    end

    def self.disable_orchestration
      #This disables the DNS/DHCP orchestration
      Host.any_instance.stubs(:boot_server).returns("boot_server")
      Resolv::DNS.any_instance.stubs(:getname).returns("foo.fqdn")
      Resolv::DNS.any_instance.stubs(:getaddress).returns("127.0.0.1")
      Net::DNS::ARecord.any_instance.stubs(:conflicts).returns([])
      Net::DNS::ARecord.any_instance.stubs(:conflicting?).returns(false)
      Net::DNS::PTRRecord.any_instance.stubs(:conflicting?).returns(false)
      Net::DNS::PTRRecord.any_instance.stubs(:conflicts).returns([])
      Net::DHCP::Record.any_instance.stubs(:create).returns(true)
      Net::DHCP::SparcRecord.any_instance.stubs(:create).returns(true)
      Net::DHCP::Record.any_instance.stubs(:conflicting?).returns(false)
      ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["production"])
      ProxyAPI::DHCP.any_instance.stubs(:unused_ip).returns('127.0.0.1')
    end

    def disable_orchestration
      ActiveSupport::TestCase.disable_orchestration
    end

    # from active_support/testing/assertions.rb and modified to restore User.current
    # as controllers reset User.current to nil after handling of a request
    def assert_difference(expression, difference = 1, message = nil, &block)
      expressions = Array.wrap expression

      exps = expressions.map { |e|
        e.respond_to?(:call) ? e : lambda { eval(e, block.binding) }
      }
      before = exps.map { |e| e.call }

      current_user = User.current
      yield
      User.current = current_user

      expressions.zip(exps).each_with_index do |(code, e), i|
        error  = "#{code.inspect} didn't change by #{difference}"
        error  = "#{message}.\n#{error}" if message
        assert_equal(before[i] + difference, e.call, error)
      end
    end
  end

  # Transactional fixtures do not work with Selenium tests, because Capybara
  # uses a separate server thread, which the transactions would be hidden
  # from. We hence use DatabaseCleaner to truncate our test database.
  DatabaseCleaner.strategy = :truncation

  class ActionDispatch::IntegrationTest
    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL

    # Stop ActiveRecord from wrapping tests in transactions
    self.use_transactional_fixtures = false
  end

  class ActionView::TestCase
    helper Rails.application.routes.url_helpers
  end

  class Location
    scope :my_locations, lambda {
      conditions = if Rails.env.test? && User.current.nil?
        {}
      elsif User.current.admin?
        { }
      else
        sanitize_sql_for_conditions([" (taxonomies.id in (?)) ", User.current.location_ids])
      end
      where(conditions).reorder('type, name')
    }
  end

  class Organization
    scope :my_organizations, lambda {
      conditions = if Rails.env.test? && User.current.nil?
        {}
      elsif User.current.admin?
        { }
      else
        sanitize_sql_for_conditions([" (taxonomies.id in (?))", User.current.organization_ids])
      end
      where(conditions).reorder('type, name')
    }
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  class ActiveSupport::TestCase
    setup :set_admin
    def set_admin
      User.current = User.unscoped.find_by_login("admin")
    end
  end

  class ActionController::TestCase
    setup :setup_set_script_name, :set_api_user

    def setup_set_script_name
      @request.env["SCRIPT_NAME"] = @controller.config.relative_url_root
    end

    def set_api_user
      return unless self.class.to_s[/api/i]
      User.current = User.unscoped.find_by_login("apiadmin")
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(User.current.login, "secret")
    end
  end

  class ActionDispatch::IntegrationTest
    setup :login_admin

    teardown do
      DatabaseCleaner.clean       # Truncate the database
      Capybara.reset_sessions!    # Forget the (simulated) browser state
      Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
    end

    private

    def login_admin
      visit "/"
      fill_in "login_login", :with => "admin"
      fill_in "login_password", :with => "secret"
      click_button "Login"
    end
  end
end
