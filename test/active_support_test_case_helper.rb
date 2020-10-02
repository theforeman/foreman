class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  set_fixture_class({ :hosts => Host::Base })
  set_fixture_class :nics => Nic::BMC

  setup :begin_gc_deferment
  setup :reset_rails_cache
  setup :skip_if_plugin_asked_to
  setup :set_admin

  teardown :reconsider_gc_deferment
  teardown :clear_current_user
  teardown :clear_current_taxonomies
  teardown :reset_rails_cache

  DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 1.0).to_f

  @@last_gc_run = Time.now.getlocal

  def begin_gc_deferment
    GC.disable if DEFERRED_GC_THRESHOLD > 0
  end

  def reconsider_gc_deferment
    if DEFERRED_GC_THRESHOLD > 0 && Time.now.getlocal - @@last_gc_run >= DEFERRED_GC_THRESHOLD
      GC.enable
      GC.start
      GC.disable

      @@last_gc_run = Time.now.getlocal
    end
  end

  def skip_if_plugin_asked_to
    skips = Foreman::Plugin.tests_to_skip[self.class.name].to_a
    if skips.any? { |name| @NAME.end_with?(name) }
      skip "Test was disabled by plugin"
    end
  end

  def set_admin
    User.current = users(:admin)
  end

  def clear_current_user
    User.current = nil
  end

  def clear_current_taxonomies
    Location.current = nil
    Organization.current = nil
  end

  def reset_rails_cache
    Rails.cache.clear
  end

  # for backwards compatibility to between Minitest syntax
  alias_method :assert_not,       :refute
  alias_method :assert_no_match,  :refute_match
  alias_method :assert_not_nil,   :refute_nil
  alias_method :assert_not_equal, :refute_equal
  alias_method :assert_raise,       :assert_raises
  alias_method :assert_include,     :assert_includes
  alias_method :assert_not_include, :assert_not_includes
  class <<self
    alias_method :context, :describe
  end

  # Add more helper methods to be used by all tests here...
  def logger
    Rails.logger
  end

  def set_session_user(user = :admin)
    user = user.is_a?(User) ? user : users(user)
    {:user => user.id, :expires_at => 5.minutes.from_now}
  end

  def as_user(user)
    saved_user   = User.current
    User.current = user.is_a?(User) ? user : users(user)
    result = yield
    User.current = saved_user
    result
  end

  def as_admin(&block)
    as_user :admin, &block
  end

  def in_taxonomy(taxonomy)
    new_taxonomy = taxonomy.is_a?(Taxonomy) ? taxonomy : taxonomies(taxonomy)
    saved_taxonomy = new_taxonomy.class.current
    new_taxonomy.class.current = new_taxonomy
    result = yield
  ensure
    new_taxonomy.class.current = saved_taxonomy
    result
  end

  def setup_users
    User.current = users :admin
    user = User.find_by_login("one")
    @request.session[:user] = user.id
    @request.session[:expires_at] = 5.minutes.from_now.to_i
    user.roles = [Role.default, Role.find_by_name('Viewer')]
    user.save!
  end

  # if a method receieves a block it will be yielded just before user save
  def setup_user(operation, type = "", search = nil, user = :one)
    @one = user.is_a?(User) ? user : users(user)
    as_admin do
      permission = Permission.find_by_name("#{operation}_#{type}") ||
        FactoryBot.build(:permission, :name => "#{operation}_#{type}")
      filter = FactoryBot.build(:filter, :search => search)
      filter.permissions = [permission]
      role = Role.where(:name => "#{operation}_#{type}").first_or_create
      role.filters = [filter]
      role.save!
      filter.role = role
      filter.save!
      @one.roles << role
      yield(@one) if block_given?
      @one.save!
    end
    User.current = @one
  end

  def unattended?
    SETTINGS[:unattended].nil? || SETTINGS[:unattended]
  end

  def skip_without_unattended
    skip("unattended mode is disabled") unless unattended?
  end

  def self.disable_orchestration
    # This disables the DNS/DHCP orchestration
    Resolv::DNS.any_instance.stubs(:getname).returns("foo.fqdn")
    Resolv::DNS.any_instance.stubs(:getaddress).returns("127.0.0.1")
    Resolv::DNS.any_instance.stubs(:getresources).returns([OpenStruct.new(:mname => 'foo', :name => 'bar')])
    Net::DNS::ARecord.any_instance.stubs(:conflicts).returns([])
    Net::DNS::ARecord.any_instance.stubs(:conflicting?).returns(false)
    Net::DNS::AAAARecord.any_instance.stubs(:conflicts).returns([])
    Net::DNS::AAAARecord.any_instance.stubs(:conflicting?).returns(false)
    Net::DNS::PTR4Record.any_instance.stubs(:conflicting?).returns(false)
    Net::DNS::PTR4Record.any_instance.stubs(:conflicts).returns([])
    Net::DNS::PTR6Record.any_instance.stubs(:conflicting?).returns(false)
    Net::DNS::PTR6Record.any_instance.stubs(:conflicts).returns([])
    Net::DHCP::Record.any_instance.stubs(:create).returns(true)
    Net::DHCP::SparcRecord.any_instance.stubs(:create).returns(true)
    Net::DHCP::Record.any_instance.stubs(:conflicting?).returns(false)
    ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["production"])
    ProxyAPI::DHCP.any_instance.stubs(:unused_ip).returns('127.0.0.1')
    ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('127.0.0.1')
  end

  def stub_smart_proxy_v2_features
    ProxyAPI::V2::Features.any_instance.stubs(:features).returns(Hash[Feature.name_map.keys.collect { |f| [f, {'state' => 'running'}] }])
  end

  def stub_smart_proxy_v2_features_and_statuses
    stub_smart_proxy_v2_features
    ProxyStatus::Version.any_instance.stubs(:version).returns({'version' => '1.11', 'modules' => {'dhcp' => '1.11'}})
    ProxyStatus::Puppet.any_instance.stubs(:environment_stats).returns({})
    ProxyStatus::PuppetCA.any_instance.stubs(:certs).returns([])
    ProxyStatus::PuppetCA.any_instance.stubs(:autosign).returns([])
    ProxyStatus::TFTP.any_instance.stubs(:server).returns('192.0.0.1')
    ProxyStatus::Logs.any_instance.stubs(:logs).returns(SmartProxies::LogBuffer.new({'logs' => []}))
  end

  def disable_orchestration
    ActiveSupport::TestCase.disable_orchestration
  end

  def read_json_fixture(file)
    json = File.expand_path(File.join('..', 'static_fixtures', file), __FILE__)
    JSON.parse(File.read(json))
  end

  def assert_with_errors(condition, model)
    assert condition, "#{model.inspect} errors: #{model.errors.full_messages.join(';')}"
  end

  def assert_valid(model)
    assert_with_errors model.valid?, model
  end

  def refute_with_errors(condition, model, field = nil, match = nil)
    refute condition, "#{model.inspect} errors: #{model.errors.full_messages.join(';')}"
    if field
      model_errors = model.errors.map { |a, m| model.errors.full_message(a, m) unless field == a }.compact
      assert model_errors.blank?, "#{model} contains #{model_errors}, it should not contain any"
      if match
        assert model.errors[field].find { |e| e.match(match) }.present?,
          "#{field} error matching #{match} not found: #{model.errors[field].inspect}"
      end
    end
  end
  alias_method :assert_not_with_errors, :refute_with_errors

  # Checks a model isn't valid.  Optionally add error field name as the second argument
  # to declare that you only want validation errors in those fields, so it will assert if
  # there are errors elsewhere on the model so you know you're testing for the right thing.
  def refute_valid(model, field = nil, match = nil)
    refute_with_errors model.valid?, model, field, match
  end
  alias_method :assert_not_valid, :refute_valid

  def with_env(values = {})
    old_values = values.inject({}) { |ov, (key, val)| ov.update(key => ENV[key]) }
    ENV.update values
    result = yield
    ENV.update old_values
    result
  end

  def next_mac(mac)
    mac.tr(':', '').to_i(16).succ.to_s(16).rjust(12, '0').scan(/../).join(':')
  end

  def fake_rest_client_response(data)
    net_http_resp = Net::HTTPResponse.new(1.0, 200, 'OK')
    req = RestClient::Request.new(:method => 'get', :url => 'http://localhost:8443')
    RestClient::Response.create(data.to_json, net_http_resp, req)
  end

  # Minitest provides a "_" expects syntax which overrides the gettext "_" method
  # Override the minitest method and call the original instead for compatibility
  # with the app's runtime environment.
  def _(*args)
    Object.instance_method(:_).bind(self).call(*args)
  end

  def assert_raises_with_message(exception, msg, &block)
    yield
  rescue => e
    assert_match msg, e.message
  else
    raise "Expected to raise #{e} w/ message #{msg}, none raised"
  end
end
