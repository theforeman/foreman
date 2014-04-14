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

# Remove previous test log to speed tests up
test_log = File.expand_path('../../log/test.log', __FILE__)
FileUtils.rm(test_log) if File.exists?(test_log)

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require "minitest/autorun"
  require 'capybara/rails'
  require 'factory_girl_rails'

  # Turn of Apipie validation for tests
  Apipie.configuration.validate = false

  # To prevent Postgres' errors "permission denied: "RI_ConstraintTrigger"
  if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
    ActiveRecord::Migration.execute "SET CONSTRAINTS ALL DEFERRED;"
  end

  class ActiveSupport::TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting
    fixtures :all
    set_fixture_class({ :hosts => Host::Base })
    set_fixture_class :nics => Nic::BMC

    setup :begin_gc_deferment
    teardown :reconsider_gc_deferment

    DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 1.0).to_f

    @@last_gc_run = Time.now

    def begin_gc_deferment
      GC.disable if DEFERRED_GC_THRESHOLD > 0
    end

    def reconsider_gc_deferment
      if DEFERRED_GC_THRESHOLD > 0 && Time.now - @@last_gc_run >= DEFERRED_GC_THRESHOLD
        GC.enable
        GC.start
        GC.disable

        @@last_gc_run = Time.now
      end
    end

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

    def in_taxonomy(taxonomy)
      new_taxonomy = taxonomies(taxonomy)
      saved_taxonomy = new_taxonomy.class.current
      new_taxonomy.class.current = new_taxonomy
      result = yield
      new_taxonomy.class.current = saved_taxonomy
      result
    end

    def setup_users
      User.current = users :admin
      user = User.find_by_login("one")
      @request.session[:user] = user.id
      @request.session[:expires_at] = 5.minutes.from_now
      user.roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
      user.save!
    end

    # if a method receieves a block it will be yielded just before user save
    def setup_user operation, type="", search = nil, user = :one
      @one = users(user)
      as_admin do
        permission = Permission.find_by_name("#{operation}_#{type}") || FactoryGirl.create(:permission, :name => "#{operation}_#{type}")
        filter = FactoryGirl.build(:filter, :search => search)
        filter.permissions = [ permission ]
        role = Role.find_or_create_by_name :name => "#{operation}_#{type}"
        role.filters = [ filter ]
        role.save!
        filter.role = role
        filter.save!
        @one.roles = [ role ]
        yield(@one) if block_given?
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

    def read_json_fixture(file)
      json = File.expand_path(File.join('..', 'fixtures', file), __FILE__)
      JSON.parse(File.read(json))
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

    def assert_index_page(index_path,title_text,new_link_text = nil,has_search = true,has_pagination = true)
      visit index_path
      assert page.has_selector?('h1', :text => title_text), "#{title_text} was expected in the <h1> tag, but was not found"
      (assert find_link(new_link_text).visible?, "#{new_link_text} is not visible") if new_link_text
      (assert find_button('Search').visible?, "Search button is not visible") if has_search
      (assert has_content?("Displaying"), "Pagination 'Display ...' does not appear") if has_pagination
    end

    def assert_new_button(index_path,new_link_text,new_path)
      visit index_path
      click_link new_link_text
      assert_equal new_path, current_path, "new path #{new_path} was expected but it was #{current_path}"
    end

    def assert_submit_button(redirect_path,button_text = "Submit")
      click_button button_text
      assert_equal redirect_path, current_path, "redirect path #{redirect_path} was expected but it was #{current_path}"
    end

    def assert_delete_row(index_path, link_text, delete_text = "Delete", dropdown = false)
      visit index_path
      within(:xpath, "//tr[contains(.,'#{link_text}')]") do
        find("i.caret").click if dropdown
        click_link(delete_text)
      end
      popup = page.driver.browser.switch_to.alert
      popup.accept
      assert page.has_no_link?(link_text), "link '#{link_text}' was expected NOT to be on the page, but it was found."
      assert page.has_content?('Successfully destroyed'), "flash message 'Successfully destroyed' was expected but it was not found on the page"
    end

    def assert_cannot_delete_row(index_path, link_text, delete_text = "Delete", dropdown = false, flash_message = true)
      visit index_path
      within(:xpath, "//tr[contains(.,'#{link_text}')]") do
        find("i.caret").click if dropdown
        click_link(delete_text)
      end
      popup = page.driver.browser.switch_to.alert
      popup.accept
      assert page.has_link?(link_text), "link '#{link_text}' was expected but it was not found on the page."
      assert page.has_content?("is used by"), "flash message 'is used by' was expected but it was not found on the page."
    end

    def fix_mismatches
      Location.all_import_missing_ids
      Organization.all_import_missing_ids
    end

  end

  class ActionView::TestCase
    helper Rails.application.routes.url_helpers
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  class ActionController::TestCase
    setup :setup_set_script_name, :set_api_user, :reset_setting_cache

    def reset_setting_cache
      Setting.cache.clear
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
