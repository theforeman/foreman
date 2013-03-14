require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require 'capybara/rails'

  class ActiveSupport::TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting

    fixtures :all

    set_fixture_class({ :hosts => Host::Base })
    # Add more helper methods to be used by all tests here...

    def logger
      Rails.logger
    end

    class Test::Unit::TestCase
      include RR::Adapters::TestUnit
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
      User.current = users :admin
      user = User.find_by_login("one")
      @request.session[:user] = user.id
      @request.session[:expires_at] = 5.minutes.from_now
      user.roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
      user.save!
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
  end

  Apipie.configuration.validate = false

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

end



Spork.each_run do
  # This code will be run each time you run your specs.
  class ActionController::TestCase
    setup :setup_set_script_name, :set_api_user

    def setup_set_script_name
      @request.env["SCRIPT_NAME"] = @controller.config.relative_url_root
    end

    def set_api_user
      return unless self.class.to_s[/api/i]
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(users(:apiadmin).login, "secret")
    end
  end

  class ActionDispatch::IntegrationTest

    def setup
      login_admin
    end

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

    def logout_admin
      click_link "Sign Out"
    end

  end

end
