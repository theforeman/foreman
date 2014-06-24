require 'test_helper'

class AuthorizerTest < ActiveSupport::TestCase
  def setup
    User.current = User.admin

    @user_role  = FactoryGirl.create(:user_user_role)
    @user       = @user_role.owner
    @role       = @user_role.role
    @permission = FactoryGirl.create(:permission, :host)
  end

  # limited, unlimited, permission with resource, without resource...
  test "#can?(:view_hosts) with unlimited filter" do
    filter     = FactoryGirl.create(:filter, :role => @role, :permissions => [@permission])
    auth       = Authorizer.new(@user)

    assert auth.can?(@permission.name.to_sym)
    refute auth.can?(:view_domains)
  end

  test "#can?(:view_hosts) with unlimited filter" do
    filter     = FactoryGirl.create(:filter, :on_name_all, :role => @role, :permissions => [@permission])
    auth       = Authorizer.new(@user)

    assert auth.can?(@permission.name.to_sym)
    refute auth.can?(:view_domains)
  end

  test "#can?(:view_hosts) on permission without resource" do
    filter     = FactoryGirl.create(:filter, :on_name_all, :role => @role, :permissions => [@permission])
    auth       = Authorizer.new(@user)

    assert auth.can?(@permission.name.to_sym)
    refute auth.can?(:view_domains)
  end

  test "#can?(:view_hosts) is limited by particular user" do
    filter     = FactoryGirl.create(:filter, :on_name_all, :role => @role, :permissions => [@permission])
    auth       = Authorizer.new(FactoryGirl.create(:user))

    refute auth.can?(@permission.name.to_sym)
  end

  test "#can?(:view_domains, @host) for unlimited filter" do
    permission = Permission.find_by_name('view_domains')
    filter     = FactoryGirl.create(:filter, :role => @role, :permissions => [permission])
    domain     = FactoryGirl.create(:domain)
    auth       = Authorizer.new(@user)

    assert_include auth.find_collection(Domain, :permission => :view_domains), domain
    assert auth.can?(:view_domains, domain)
  end

  test "#can?(:view_domains, @host) for matching limited filter" do
    permission = Permission.find_by_name('view_domains')
    filter     = FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                    :search        => 'name ~ example*')
    domain     = FactoryGirl.create(:domain)
    auth       = Authorizer.new(@user)

    assert_include auth.find_collection(Domain, :permission => :view_domains), domain
    assert auth.can?(:view_domains, domain)
  end

  test "#can?(:view_domains, @host) for matching and not matching limited filter" do
    permission = Permission.find_by_name('view_domains')
    not_matching_filter = FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                             :search        => 'name ~ noexample*')
    matching_filter     = FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                             :search        => 'name ~ example*')
    domain              = FactoryGirl.create(:domain)
    auth                = Authorizer.new(@user)

    assert_include auth.find_collection(Domain, :permission => :view_domains), domain
    assert auth.can?(:view_domains, domain)
  end

  test "#can?(:view_domains, @host) for not matching limited filter" do
    permission = Permission.find_by_name('view_domains')
    filter     = FactoryGirl.create(:filter, :role => @role, :permissions => [permission],
                                    :search        => 'name ~ noexample*')
    domain     = FactoryGirl.create(:domain)
    auth       = Authorizer.new(@user)

    assert_not_include auth.find_collection(Domain, :permission => :view_domains), domain
    refute auth.can?(:view_domains, domain)
  end

  test "#can?(:view_domains, @host) filters records by matching limited filter" do
    permission = Permission.find_by_name('view_domains')
    filter     = FactoryGirl.create(:filter, :on_name_starting_with_a,
                                    :role => @role, :permissions => [permission])
    domain1    = FactoryGirl.create(:domain)
    domain2    = FactoryGirl.create(:domain, :name => 'a-domain.to-be-found.com')
    auth       = Authorizer.new(@user)

    collection = auth.find_collection(Domain, :permission => :view_domains)
    assert_not_include collection, domain1
    assert_include collection, domain2
    refute auth.can?(:view_domains, domain1)
    assert auth.can?(:view_domains, domain2)
  end

  test "#can?(:view_domains, @host) filters records by matching limited filter and permission" do
    permission1 = Permission.find_by_name('view_domains')
    permission2 = Permission.find_by_name('edit_domains')
    filter1     = FactoryGirl.create(:filter, :on_name_starting_with_a,
                                     :role => @role, :permissions => [permission1])
    filter2     = FactoryGirl.create(:filter, :on_name_starting_with_b,
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
    filter4 = FactoryGirl.create(:filter, :role => @role, :permissions => [permission1])
    collection = auth.find_collection(Domain)
    assert_include collection, domain1
    assert_include collection, domain2
    assert_include collection, domain3
    assert_include collection, domain4
  end

  test "#can?(:view_domains, @host) for user without filter" do
    permission = Permission.find_by_name('view_domains')
    filter     = FactoryGirl.create(:filter, :role => @role, :permissions => [permission])
    domain     = FactoryGirl.create(:domain)
    auth       = Authorizer.new(FactoryGirl.create(:user))

    result = auth.find_collection(Domain, :permission => :view_domains)
    assert_not_include result, domain
    assert_kind_of ActiveRecord::Relation, result
    refute auth.can?(:view_domains, domain)
  end

  test "#can? caches results per permission and class" do
    permission1 = Permission.find_by_name('view_domains')
    filter1     = FactoryGirl.create(:filter, :on_name_starting_with_a,
                                     :role => @role, :permissions => [permission1])
    domain1     = FactoryGirl.create(:domain, :name => 'a-domain.to-be-found.com')
    domain2     = FactoryGirl.create(:domain, :name => 'x-domain.not-to-be-found.com')
    permission2 = Permission.find_by_name('view_architectures')
    architecture = FactoryGirl.create(:architecture)
    filter2      = FactoryGirl.create(:filter, :role => @role, :permissions => [permission2])

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
    filter     = FactoryGirl.create(:filter, :role => @role, :permissions => [permission])
    auth       = Authorizer.new(@user, :collection => [])

    refute auth.can?(:view_domains, domain)
  end

  test "#can? with excluding base collection set" do
    permission = Permission.find_by_name('view_domains')
    filter1    = FactoryGirl.create(:filter, :on_name_starting_with_a,
                                     :role => @role, :permissions => [permission])
    domain1    = FactoryGirl.create(:domain, :name => 'a-domain.to-be-found.com')
    domain2    = FactoryGirl.create(:domain, :name => 'another-domain.to-be-found.com')
    auth       = Authorizer.new(@user, :collection => [domain2])

    refute auth.can?(:view_domains, domain1)
    assert auth.can?(:view_domains, domain2)
  end
end
