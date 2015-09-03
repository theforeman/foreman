require 'test_helper'

class AuthorizerTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin

    @user_role  = FactoryGirl.create(:user_user_role)
    @user       = @user_role.owner
    @role       = @user_role.role
    @permission = FactoryGirl.create(:permission, :host)
  end

  # limited, unlimited, permission with resource, without resource...
  test "#can?(:view_hosts) with unlimited filter" do
    FactoryGirl.create(:filter, :role => @role, :permissions => [@permission])
    auth       = Authorizer.new(@user)

    assert auth.can?(@permission.name.to_sym)
    refute auth.can?(:view_domains)
  end

  test "#can?(:view_hosts) with unlimited filter" do
    FactoryGirl.create(:filter, :on_name_all, :role => @role, :permissions => [@permission])
    auth       = Authorizer.new(@user)

    assert auth.can?(@permission.name.to_sym)
    refute auth.can?(:view_domains)
  end

  test "#can?(:view_hosts) on permission without resource" do
    FactoryGirl.create(:filter, :on_name_all, :role => @role, :permissions => [@permission])
    auth       = Authorizer.new(@user)

    assert auth.can?(@permission.name.to_sym)
    refute auth.can?(:view_domains)
  end

  test "#can?(:view_hosts) is limited by particular user" do
    FactoryGirl.create(:filter, :on_name_all, :role => @role, :permissions => [@permission])
    auth       = Authorizer.new(FactoryGirl.create(:user))

    refute auth.can?(@permission.name.to_sym)
  end

  test "#can?(:view_domains, @host) for unlimited filter" do
    permission = Permission.find_by_name('view_domains')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission])
    domain     = FactoryGirl.create(:domain)
    auth       = Authorizer.new(@user)

    assert_includes auth.find_collection(Domain, :permission => :view_domains), domain
    assert auth.can?(:view_domains, domain)
  end

  test "#can?(:view_domains, @host) for matching limited filter" do
    permission = Permission.find_by_name('view_domains')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                :search => 'name ~ example*')
    domain     = FactoryGirl.create(:domain)
    auth       = Authorizer.new(@user)

    assert_includes auth.find_collection(Domain, :permission => :view_domains), domain
    assert auth.can?(:view_domains, domain)
  end

  test "#can?(:view_domains, @host) for matching and not matching limited filter" do
    permission = Permission.find_by_name('view_domains')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                :search => 'name ~ noexample*')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                :search        => 'name ~ example*')
    domain              = FactoryGirl.create(:domain)
    auth                = Authorizer.new(@user)

    assert_includes auth.find_collection(Domain, :permission => :view_domains), domain
    assert auth.can?(:view_domains, domain)
  end

  test "#can?(:view_domains, @host) for not matching limited filter" do
    permission = Permission.find_by_name('view_domains')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                :search        => 'name ~ noexample*')
    domain     = FactoryGirl.create(:domain)
    auth       = Authorizer.new(@user)

    assert_not_includes auth.find_collection(Domain, :permission => :view_domains), domain
    refute auth.can?(:view_domains, domain)
  end

  test "#can?(:view_domains, @host) filters records by matching limited filter" do
    permission = Permission.find_by_name('view_domains')
    FactoryGirl.create(:filter, :on_name_starting_with_a,
                                :role => @role, :permissions => [permission])
    domain1    = FactoryGirl.create(:domain)
    domain2    = FactoryGirl.create(:domain, :name => 'a-domain.to-be-found.com')
    auth       = Authorizer.new(@user)

    collection = auth.find_collection(Domain, :permission => :view_domains)
    assert_not_includes collection, domain1
    assert_includes collection, domain2
    refute auth.can?(:view_domains, domain1)
    assert auth.can?(:view_domains, domain2)
  end

  test "#can?(:view_domains, @host) filters records by matching limited filter and permission" do
    permission1 = Permission.find_by_name('view_domains')
    permission2 = Permission.find_by_name('edit_domains')
    FactoryGirl.create(:filter, :on_name_starting_with_a,
                                :role => @role, :permissions => [permission1])
    FactoryGirl.create(:filter, :on_name_starting_with_b,
                                :role => @role, :permissions => [permission2])
    domain1     = FactoryGirl.create(:domain)
    domain2     = FactoryGirl.create(:domain, :name => 'a-domain.to-be-found.com')
    domain3     = FactoryGirl.create(:domain, :name => 'another-domain.to-be-found.com')
    domain4     = FactoryGirl.create(:domain, :name => 'be_editable.to-be-found.com')
    auth        = Authorizer.new(@user)

    collection = auth.find_collection(Domain, :permission => :view_domains)
    assert_equal [domain2, domain3], collection
    collection = auth.find_collection(Domain, :permission => :edit_domains)
    assert_equal [domain4], collection
    collection = auth.find_collection(Domain, :permission => :delete_domains)
    assert_equal [], collection
    collection = auth.find_collection(Domain)
    assert_equal [domain2, domain3, domain4], collection

    refute auth.can?(:view_domains, domain1)
    assert auth.can?(:view_domains, domain2)
    assert auth.can?(:view_domains, domain3)
    refute auth.can?(:view_domains, domain4)
    refute auth.can?(:edit_domains, domain1)
    refute auth.can?(:edit_domains, domain2)
    refute auth.can?(:edit_domains, domain3)
    assert auth.can?(:edit_domains, domain4)

    # unlimited filter on Domain permission does add the domain
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission1])
    collection = auth.find_collection(Domain)
    assert_includes collection, domain1
    assert_includes collection, domain2
    assert_includes collection, domain3
    assert_includes collection, domain4
  end

  test "#can?(:view_domains, @host) for user without filter" do
    permission = Permission.find_by_name('view_domains')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission])
    domain     = FactoryGirl.create(:domain)
    auth       = Authorizer.new(FactoryGirl.create(:user))

    result = auth.find_collection(Domain, :permission => :view_domains)
    assert_not_includes result, domain
    assert_kind_of ActiveRecord::Relation, result
    refute auth.can?(:view_domains, domain)
  end

  test "#can? caches results per permission and class" do
    permission1 = Permission.find_by_name('view_domains')
    FactoryGirl.create(:filter, :on_name_starting_with_a,
                                 :role => @role, :permissions => [permission1])
    domain1     = FactoryGirl.create(:domain, :name => 'a-domain.to-be-found.com')
    domain2     = FactoryGirl.create(:domain, :name => 'x-domain.not-to-be-found.com')
    permission2 = Permission.find_by_name('view_architectures')
    architecture = FactoryGirl.create(:architecture)
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission2])

    auth        = Authorizer.new(@user)

    auth.stubs(:find_collection).returns([domain1]).times(3)
    assert auth.can?(:view_domain, domain1)
    refute auth.can?('view_domain', domain2)
    assert auth.can?(:edit_domain, domain1)
    refute auth.can?('edit_domain', domain2)
    refute auth.can?(:view_architectures, architecture) # since it's stubbed and returns domain1 only
    refute auth.can?('view_architectures', architecture)
  end

  test "#build_scoped_search_condition(filters) for empty set" do
    auth = Authorizer.new(FactoryGirl.create(:user))
    assert_raises ArgumentError do
      auth.build_scoped_search_condition([])
    end
  end

  test "#build_scoped_search_condition(filters) for one filter" do
    auth    = Authorizer.new(FactoryGirl.create(:user))
    filters = [FactoryGirl.build(:filter, :on_name_all)]
    result  = auth.build_scoped_search_condition(filters)

    assert_equal '(name ~ *)', result
  end

  test "#build_scoped_search_condition(filters) for more filters" do
    auth    = Authorizer.new(FactoryGirl.create(:user))
    filters = [FactoryGirl.build(:filter, :on_name_all), FactoryGirl.build(:filter, :on_name_starting_with_a)]
    result  = auth.build_scoped_search_condition(filters)

    assert_equal '(name ~ *) OR (name ~ a*)', result
  end

  test "#build_scoped_search_condition(filters) for unlimited filter" do
    auth    = Authorizer.new(FactoryGirl.create(:user))
    filters = [FactoryGirl.build(:filter)]
    result  = auth.build_scoped_search_condition(filters)

    assert_equal '(1=1)', result
  end

  test "#build_scoped_search_condition(filters) for limited and unlimited filter" do
    auth    = Authorizer.new(FactoryGirl.create(:user))
    filters = [FactoryGirl.build(:filter, :on_name_all), FactoryGirl.build(:filter)]
    result  = auth.build_scoped_search_condition(filters)

    assert_equal '(name ~ *) OR (1=1)', result
  end

  test "#build_scoped_search_condition(filters) for empty filter" do
    auth    = Authorizer.new(FactoryGirl.create(:user))
    filters = [FactoryGirl.build(:filter, :search => '')]
    result  = auth.build_scoped_search_condition(filters)

    assert_equal '(1=1)', result
  end

  test "#can? with empty base collection set" do
    domain     = FactoryGirl.create(:domain)
    permission = Permission.find_by_name('view_domains')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission])
    auth       = Authorizer.new(@user, :collection => [])

    refute auth.can?(:view_domains, domain)
  end

  test "#can? with excluding base collection set" do
    permission = Permission.find_by_name('view_domains')
    FactoryGirl.create(:filter, :on_name_starting_with_a,
                                :role => @role, :permissions => [permission])
    domain1    = FactoryGirl.create(:domain, :name => 'a-domain.to-be-found.com')
    domain2    = FactoryGirl.create(:domain, :name => 'another-domain.to-be-found.com')
    auth       = Authorizer.new(@user, :collection => [domain2])

    refute auth.can?(:view_domains, domain1)
    assert auth.can?(:view_domains, domain2)
  end

  test "#find_collection(Host, :permission => :view_hosts) with scoped_search join returns r/w resources" do
    host       = FactoryGirl.create(:host, :with_facts)
    fact       = host.fact_values.first
    permission = Permission.find_by_name('view_hosts')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                :search => "facts.#{fact.name} = #{fact.value}")
    auth       = Authorizer.new(@user)

    results = auth.find_collection(Host::Managed, :permission => :view_hosts)
    assert_includes results, host
    refute results.grep(host).first.readonly?
  end

  test "#find_collection(Host, :permission => :view_hosts, :joined_on: Report) for admin" do
    host       = FactoryGirl.create(:host)
    report     = FactoryGirl.create(:config_report, :host => host)
    @user.update_attribute(:admin, true)
    auth       = Authorizer.new(@user)

    assert_includes auth.find_collection(Host::Managed, :permission => :view_hosts, :joined_on => Report), report
  end

  test "#find_collection(Host, :permission => :view_hosts, :joined_on: Report) for matching unlimited filter" do
    permission = Permission.find_by_name('view_hosts')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission], :unlimited => true)
    host       = FactoryGirl.create(:host)
    report     = FactoryGirl.create(:config_report, :host => host)
    auth       = Authorizer.new(@user)

    assert_includes auth.find_collection(Host::Managed, :permission => :view_hosts, :joined_on => Report), report
  end

  test "#find_collection(Host, :permission => :view_hosts, :joined_on: Report) for matching limited filter" do
    permission = Permission.find_by_name('view_hosts')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                :search => 'hostgroup ~ hostgroup*')
    host       = FactoryGirl.create(:host, :with_hostgroup)
    report     = FactoryGirl.create(:config_report, :host => host)
    auth       = Authorizer.new(@user)

    assert_includes auth.find_collection(Host::Managed, :permission => :view_hosts, :joined_on => Report), report
  end

  test "#find_collection(Host, :permission => :view_hosts, :joined_on: Report) for matching limited filter with base collection set" do
    permission = Permission.find_by_name('view_hosts')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                :search => 'hostgroup ~ hostgroup*')
    (host1, host2) = FactoryGirl.create_pair(:host, :with_hostgroup)
    report1        = FactoryGirl.create(:config_report, :host => host1)
    report2        = FactoryGirl.create(:config_report, :host => host2)
    auth           = Authorizer.new(@user, :collection => [host2])

    collection = auth.find_collection(Host::Managed, :permission => :view_hosts, :joined_on => Report)
    refute_includes collection, report1
    assert_includes collection, report2
  end

  test "#find_collection(Host, :permission => :view_hosts, :joined_on: Report, :where => ..) applies where clause" do
    permission = Permission.find_by_name('view_hosts')
    FactoryGirl.create(:filter, :role => @role, :permissions => [permission], :unlimited => true)
    hosts      = FactoryGirl.create_pair(:host)
    report1    = FactoryGirl.create(:config_report, :host => hosts.first)
    report2    = FactoryGirl.create(:config_report, :host => hosts.last)
    auth       = Authorizer.new(@user)

    collection = auth.find_collection(Host::Managed, :permission => :view_hosts, :joined_on => Report,
                                      :where => {'name' => hosts.first.name})
    assert_includes collection, report1
    refute_includes collection, report2
  end
end
