ENV["RAILS_ENV"] = "test"
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'mocha/minitest'
require 'capybara/rails'
require 'capybara/minitest'
require 'factory_bot_rails'
require 'show_me_the_cookies'
require 'database_cleaner'
require 'active_support_test_case_helper'
require 'minitest/retry'
require 'selenium/webdriver'
require 'test_report_helper'

retry_count = (ENV['MINITEST_RETRY_COUNT'] || 3).to_i rescue 1
Minitest::Retry.use!(retry_count: retry_count) if retry_count > 1

Minitest::Retry.on_consistent_failure do |klass, test_name|
  Rails.logger.error("DO NOT IGNORE - Consistent failure - #{klass} #{test_name}")
end

Selenium::WebDriver::Chrome::Service.driver_path = ENV['TESTDRIVER_PATH'] || Foreman::Util.which('chromedriver', Rails.root.join('node_modules', '.bin'))

javascript_driver = ENV.fetch("JS_TEST_DRIVER") { ENV['DEBUG_JS_TEST'] ? :selenium_chrome : :selenium_chrome_headless }.to_sym

def chrome_options
  options = Selenium::WebDriver::Chrome::Options.new
  options.args << '--window-size=1024,768'
  options.args += ENV.fetch('ADDITIONAL_CHROME_OPTIONS', '').split(';')
  options
end

if javascript_driver == :selenium_chrome_remote
  ShowMeTheCookies.register_adapter(:selenium_chrome_remote, ShowMeTheCookies::SeleniumChrome)

  Capybara.register_driver :selenium_chrome_remote do |app|
    selenium_remote_host = ENV.fetch('SELENIUM_REMOTE_HOST')
    selenium_remote_port = ENV.fetch('SELENIUM_REMOTE_PORT', 4444)
    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: "http://#{selenium_remote_host}:#{selenium_remote_port}/wd/hub",
      options: chrome_options)
  end
elsif javascript_driver == :selenium_chrome_headless
  options = chrome_options
  options.args << '--headless'
  Capybara.register_driver :selenium_chrome_headless do |app|
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: options)
  end
else
  Capybara.register_driver javascript_driver do |app|
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: chrome_options)
  end
end

Capybara.configure do |config|
  config.javascript_driver = javascript_driver
  config.default_max_wait_time = 20
  config.enable_aria_label = true
  if ENV.fetch("JS_TEST_DRIVER", nil) == 'selenium_chrome_remote'
    app_host = ENV.fetch('APP_SERVER_HOST') do
      Socket.ip_address_list
        .find(&:ipv4_private?)
        .ip_address
    end
    app_port = ENV.fetch('APP_SERVER_PORT', "8080")
    config.server_port = app_port
    # application server
    config.server_host = "0.0.0.0"
    # address used by selenium host to connect to application server
    config.app_host = "http://#{app_host}:#{app_port}"
  end
end

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

  # see: https://stackoverflow.com/questions/70441796/selenium-webdriver-for-aws-device-farm-error-when-sending-period-keystroke-t

  def work_around_selenium_file_detector_bug
    page.driver.browser.file_detector = nil if page.driver.browser.respond_to?(:file_detector=)
  end

  def assert_index_page(index_path, title_text, new_link_text = nil, has_search = true, has_pagination = true)
    visit index_path
    assert_breadcrumb_text(title_text)
    (assert first(:link, new_link_text).visible?, "#{new_link_text} is not visible") if new_link_text
    (assert find('.autocomplete-search button').visible?, "Search button is not visible") if has_search
  end

  def assert_breadcrumb_text(text)
    assert page.has_selector?(:xpath, "//section//div[contains(@class, 'breadcrumb-bar') or contains(@id, 'breadcrumb')]  //*[contains(.,'#{text}')]"), "#{text} was expected in //section//div[contains(@class, 'breadcrumb-bar') or contains(@id, 'breadcrumb')], but was not found"
  end

  def assert_new_button(index_path, new_link_text, new_path)
    visit index_path
    click_link(new_link_text, :class => /^((?!pf-c-nav__link).)*$/)
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

  def select2_selector(name)
    "#select2-#{name}-container"
  end

  def select2_result_selector(name)
    "#select2-#{name}-container .select2-results"
  end

  def select2_chosen_selector(name)
    find(select2_selector(name), visible: false, wait: 10).ancestor('.select2-container')
  end

  def select2(value, attrs)
    find(select2_selector(attrs[:from]), visible: false).ancestor('.select2-container').click
    wait_for { find('.select2-search__field').visible? rescue false }
    # set(value) errors on not interactable error even though the element is visible and not disabled
    page.execute_script("arguments[0].value = arguments[1];", find('.select2-search__field').native, value)
    wait_for { find('.select2-results').visible? rescue false }
    within ".select2-results__options" do
      wait_for { find(".select2-results__options li", text: value).visible? rescue false }
      find("li", text: value).hover
      find("li", text: value).click
    end
    sleep 0.15
    select2_chosen_selector(attrs[:from]).has_text? value
  end

  def wait_for
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.15 until (result = yield)
      result
    end
  end

  def wait_for_ajax
    wait_for do
      ([page.evaluate_script('jQuery.active'), page.evaluate_script('window.axiosActive')] - [0, nil]).empty?
    end
  end

  def wait_for_modal
    wait_for do
      find(:css, '#interfaceModal').visible?
    end
  end

  def wait_for_element(*args)
    wait_for do
      find(*args).visible? rescue false
    end
  end

  def cookie_named(name)
    page.driver.browser.manage.cookie_named(name)
  end

  def cookie_value(name)
    cookie_named(name) && cookie_named(name)[:value]
  end

  def has_editor_display?(css_locator, text)
    has_css?("#{css_locator} .ace_content", text: text)
  end

  # Works only with css locator
  def fill_in_editor_field(css_locator, text)
    # the input is not visible for chrome driver
    find("#{css_locator} .ace_editor.ace_input").click
    has_css?("#{css_locator} .ace_editor.ace_input")
    find("#{css_locator} .ace_input .ace_text-input", visible: :all).send_keys text
    # wait for the debounce
    has_editor_display?(css_locator, text)
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
    within('#location-dropdown ul', visible: :all) do
      assert page.has_link?(location)
    end
  end

  def refute_available_location(location)
    within('#location-dropdown ul', visible: :all) do
      assert page.has_no_link?(location)
    end
  end

  def assert_available_organization(organization)
    within('#organization-dropdown ul', visible: :all) do
      assert page.has_link?(organization)
    end
  end

  def refute_available_organization(organization)
    # value of $header-max-width is 1062px
    if (Capybara.current_session.current_window.size[0] <= 1062)
      refute_available_organization_menu(organization)
    else
      refute_available_organization_dropdown(organization)
    end
  end

  def refute_available_organization_menu(organization)
    within('.location-menu') do
      first('button').click
      within('.location-menu section ul', visible: :all) do
        assert page.has_no_link?(organization)
      end
    end
  end

  def refute_available_organization_dropdown(organization)
    within('#location-dropdown') do
      find('.pf-c-context-selector__toggle').click
      within('.pf-c-context-selector__menu>div>ul', visible: :all) do
        assert page.has_no_link?(organization)
      end
      find('.pf-c-context-selector__toggle').click
    end
  end

  def assert_current_organization(organization)
    within('#organization-dropdown > a') do
      assert page.has_content?(organization)
    end
  end

  def assert_current_location(location)
    within('#location-dropdown > a') do
      assert page.has_content?(location)
    end
  end

  def select_organization(organization)
    # value of $header-max-width is 1062px
    if (Capybara.current_session.current_window.size[0] <= 1062)
      select_organization_menu(organization)
    else
      select_organization_dropdown(organization)
    end
  end

  def select_organization_dropdown(organization)
    within('#organization-dropdown') do
      find('.pf-c-context-selector__toggle').click
      find("button.organization_menuitem", text: organization).click
    end
  end

  def select_organization_menu(organization)
    within('.organization-menu') do
      first('button').click
      find("li.pf-c-nav__item", text: organization).click
    end
  end

  def select_location_dropdown(location)
    within('#location-dropdown') do
      find('.pf-c-context-selector__toggle').click
      find("button.location_menuitem", text: location).click
    end
  end

  def assert_form_tab(label)
    within('form .nav-tabs') do
      assert page.has_content?(label)
    end
  end

  def switch_form_tab(name)
    within('form .nav-tabs') do
      click_link name
    end
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
    visit('/users/login') if Capybara.current_driver.to_s.include? "selenium"
    SSO.register_method(TestSSO)
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

  def before_setup
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
