ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'rr'
require 'mocha'
require 'shoulda'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  # Add more helper methods to be used by all tests here...

  def logger
    RAILS_DEFAULT_LOGGER
  end

  class Test::Unit::TestCase
    include RR::Adapters::TestUnit
  end

  def set_session_user
    if SETTINGS[:login]
      {:user => User.find_by_login("admin")}
    else
      {}
    end
  end

  def as_admin
    saved_user   = User.current
    User.current = users(:admin)
    result = yield
    User.current = saved_user
    result
  end

  def unattended?
    SETTINGS[:unattended].nil? or SETTINGS[:unattended]
  end

  def self.disable_orchestration
    #This disables the DNS/DHCP orchestration
    Host.any_instance.stubs(:boot_server).returns("boot_server")
    Resolv::DNS.any_instance.stubs(:getname).returns("foo.fqdn")
    Resolv::DNS.any_instance.stubs(:getaddress).returns("127.0.0.1")
    Net::DNS::ARecord.any_instance.stubs(:conflicting?).returns(false)
    Net::DNS::PTRRecord.any_instance.stubs(:conflicting?).returns(false)
  end

  def disable_orchestration
    ActiveSupport::TestCase.disable_orchestration
  end
end
