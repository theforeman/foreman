ENV["RAILS_ENV"] = "test"
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'capybara/rails'
require 'capybara/minitest'
require 'factory_bot_rails'
require 'capybara/poltergeist'
require 'show_me_the_cookies'
require 'database_cleaner'
require 'active_support_test_case_helper'
require 'minitest/retry'
require 'selenium/webdriver'

retry_count = (ENV['MINITEST_RETRY_COUNT'] || 3).to_i rescue 1
Minitest::Retry.use!(retry_count: retry_count) if retry_count > 1

Minitest::Retry.on_consistent_failure do |klass, test_name|
  Rails.logger.error("DO NOT IGNORE - Consistent failure - #{klass} #{test_name}")
end

if ENV["JS_TEST_DRIVER"] == 'selenium_chrome'
  Selenium::WebDriver::Chrome.driver_path = ENV['TESTDRIVER_PATH'] || File.join(Rails.root, 'node_modules', '.bin', 'chromedriver')
  Capybara.register_driver :selenium_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.args << '--disable-gpu'
    options.args << '--no-sandbox'
    options.args << '--window-size=1024,768'
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
  Capybara.javascript_driver = :selenium_chrome
else
  Capybara.register_driver :poltergeist do |app|
    opts = {
      # To enable debugging uncomment `:inspector => true` and
      # add `page.driver.debug` in code to open webkit inspector
      # :inspector => true
      :js_errors => true,
      :timeout => 30,
      :extensions => ["#{Rails.root}/test/integration/support/poltergeist_onload_extensions.js"],
      :phantomjs => File.join(Rails.root, 'node_modules', '.bin', 'phantomjs')
    }
    Capybara::Poltergeist::Driver.new(app, opts)
  end
  Capybara.javascript_driver = :poltergeist
end

Capybara.default_max_wait_time = 30

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include ShowMeTheCookies

  class << self
    alias_method :test, :it
  end

  # Stop ActiveRecord from wrapping tests in transactions
  self.use_transactional_tests = false

  def assert_index_page(index_path, title_text, new_link_text = nil, has_search = true, has_pagination = true)
    visit index_path
    assert page.has_selector?(:xpath, "//div[@id='breadcrumb'and contains(.,'#{title_text}')]"), "#{title_text} was expected in the div[@breadcrumb] tag, but was not found"
    (assert first(:link, new_link_text).visible?, "#{new_link_text} is not visible") if new_link_text
    (assert find_button('Search').visible?, "Search button is not visible") if has_search
  end

  def assert_new_button(index_path, new_link_text, new_path)
    visit index_path
    first(:link, new_link_text).click
    assert_current_path new_path
  end

  def assert_submit_button(redirect_path, button_text = "Submit")
    click_button button_text
    assert_current_path redirect_path
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

  def select2(value, attrs)
    find("#s2id_#{attrs[:from]}").click
    find(".select2-input").set(value)
    within ".select2-results" do
      find("span", text: value).click
    end
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.15 until ([page.evaluate_script('jQuery.active'), page.evaluate_script('window.axiosActive')] - [0, nil]).empty?
    end
  end

  def close_interfaces_modal
    click_button 'Ok' # close interfaces
    # wait for the dialog to close
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop while find(:css, '#interfaceModal', :visible => false).visible?
    end
  end

  def login_user(username, password)
    logout_admin
    visit "/"
    fill_in "login_login", :with => username
    fill_in "login_password", :with => password
    click_button "Log In"
    assert_current_path root_path
  end

  def set_empty_default_context(user)
    user.update_attribute :default_organization_id, nil
    user.update_attribute :default_location_id, nil
  end

  def set_default_context(user, org, loc)
    user.update_attribute :default_organization_id, org.try(:id)
    user.update_attribute :default_location_id, loc.try(:id)
  end

  def assert_available_location(location)
    within('li#location-dropdown ul') do
      assert page.has_link?(location)
    end
  end

  def refute_available_location(location)
    within('li#location-dropdown ul') do
      assert page.has_no_link?(location)
    end
  end

  def assert_available_organization(organization)
    within('li#organization-dropdown ul') do
      assert page.has_link?(organization)
    end
  end

  def refute_available_organization(organization)
    within('li#location-dropdown ul') do
      assert page.has_no_link?(organization)
    end
  end

  def assert_current_organization(organization)
    within('li#organization-dropdown > a') do
      assert page.has_content?(organization)
    end
  end

  def assert_current_location(location)
    within('li#location-dropdown > a') do
      assert page.has_content?(location)
    end
  end

  def select_organization(organization)
    within('li#organization-dropdown ul') do
      click_link organization
    end
  end

  def select_location(location)
    within('li#location-dropdown ul') do
      click_link location
    end
  end

  def assert_warning(message)
    assert warning_notificication_messages.include?(message)
  end

  def assert_form_tab(label)
    within(%(label[for="#{label.singularize.underscore}_ids"])) do
      assert page.has_content?(label)
    end
  end

  def warning_notificication_messages
    warning_notificications_data.map { |n| n['message'] }
  end

  def warning_notificications_data
    notifications_data.select { |n| n['type'] == "warning" }
  end

  def notifications_data
    JSON.parse(page.find(:css, "div#toast-notifications-container")['data-notifications']).map { |n| Hash[n]}
  end

  setup :start_database_cleaner, :login_admin

  teardown do
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
    SSO.deregister_method(TestSSO)
    DatabaseCleaner.clean       # Truncate the database
  end

  private

  def start_database_cleaner
    DatabaseCleaner.strategy = database_cleaner_strategy
    DatabaseCleaner.start
  end

  def database_cleaner_strategy
    :transaction
  end

  def login_admin
    SSO.register_method(TestSSO)
    visit('/users/login') if Capybara.current_driver == :selenium_chrome
    set_request_user(:admin)
  end

  def logout_admin
    delete_cookie('test_user')
  end

  def set_request_user(user)
    user = users(user) unless user.is_a?(User)
    create_cookie('test_user', user.login)
  end

  def with_controller_caching(*controller_klasses)
    controller_klasses.each { |c| c.perform_caching = true }
    yield
  ensure
    controller_klasses.each { |c| c.perform_caching = false }
  end
end

class IntegrationTestWithJavascript < ActionDispatch::IntegrationTest
  def database_cleaner_strategy
    :truncation
  end

  def login_admin
    Capybara.current_driver = Capybara.javascript_driver
    super
  end
end

class TestSSO < SSO::Base
  def available?
    Rails.env.test? && request.cookies['test_user'].present?
  end

  def authenticated?
    self.user = request.cookies['test_user']
  end
end
