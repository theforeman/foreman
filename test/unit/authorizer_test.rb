require 'test_helper'

class AuthorizerTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin

    @user_role  = FactoryBot.create(:user_user_role)
    @user       = @user_role.owner
    @role       = @user_role.role
    @permission = FactoryBot.create(:permission, :host)
  end

  describe '#can?' do
    test "it always returns true for admin" do
      @user = FactoryBot.create(:user, :admin)
      assert Authorizer.new(@user).can?(:whatever)
    end

    [true, false].each do |cache|
      context "with cache = #{cache}" do
        context 'without subject' do
          # permission with resource, without resource...
          test "with filter" do
            FactoryBot.create(:filter, :role => @role, :permissions => [@permission])
            auth = Authorizer.new(@user)

            assert auth.can?(@permission.name.to_sym, nil, cache)
            refute auth.can?(:view_domains, nil, cache)
          end
          test "permission without resource" do
            FactoryBot.create(:filter, :on_name_all, :role => @role, :permissions => [@permission])
            auth = Authorizer.new(@user)

            assert auth.can?(@permission.name.to_sym, nil, cache)
            refute auth.can?(:view_domains, nil, cache)
          end

          test "limited by particular user" do
            FactoryBot.create(:filter, :on_name_all, :role => @role, :permissions => [@permission])
            auth = Authorizer.new(FactoryBot.create(:user))

            refute auth.can?(@permission.name.to_sym, nil, cache)
          end
        end

        context 'with subject (e.g: Domain)' do
          test "filter" do
            permission = Permission.find_by_name('view_domains')
            FactoryBot.create(:filter, :role => @role, :permissions => [permission])
            domain     = FactoryBot.create(:domain)
            auth       = Authorizer.new(@user)

            assert_includes auth.find_collection(Domain, :permission => :view_domains), domain
            assert auth.can?(:view_domains, domain, cache)
          end

          test "matching and not matching filter" do
            permission = Permission.find_by_name('view_domains')
            FactoryBot.create(:filter, :role => @role, :permissions => [permission],
                               :search => 'name ~ noexample*')
            FactoryBot.create(:filter, :role => @role, :permissions => [permission],
                               :search        => 'name ~ example*')
            domain = FactoryBot.create(:domain)
            auth = Authorizer.new(@user)

            assert_includes auth.find_collection(Domain, :permission => :view_domains), domain
            assert auth.can?(:view_domains, domain, cache)
          end

          test "not matching filter" do
            permission = Permission.find_by_name('view_domains')
            FactoryBot.create(:filter, :role => @role, :permissions => [permission],
                               :search        => 'name ~ noexample*')
            domain     = FactoryBot.create(:domain)
            auth       = Authorizer.new(@user)

            assert_not_includes auth.find_collection(Domain, :permission => :view_domains), domain
            refute auth.can?(:view_domains, domain, cache)
          end

          test "filters records by matching filter" do
            permission = Permission.find_by_name('view_domains')
            FactoryBot.create(:filter, :on_name_starting_with_a,
              :role => @role, :permissions => [permission])
            domain1    = FactoryBot.create(:domain)
            domain2    = FactoryBot.create(:domain, :name => 'a-domain.to-be-found.com')
            auth       = Authorizer.new(@user)

            collection = auth.find_collection(Domain, :permission => :view_domains)
            assert_not_includes collection, domain1
            assert_includes collection, domain2
            refute auth.can?(:view_domains, domain1, cache)
            assert auth.can?(:view_domains, domain2, cache)
          end

          test "filters records by matching limited filter and permission" do
            permission1 = Permission.find_by_name('view_domains')
            permission2 = Permission.find_by_name('edit_domains')
            FactoryBot.create(:filter, :on_name_starting_with_a,
              :role => @role, :permissions => [permission1])
            FactoryBot.create(:filter, :on_name_starting_with_b,
              :role => @role, :permissions => [permission2])
            domain1     = FactoryBot.create(:domain)
            domain2     = FactoryBot.create(:domain, :name => 'a-domain.to-be-found.com')
            domain3     = FactoryBot.create(:domain, :name => 'another-domain.to-be-found.com')
            domain4     = FactoryBot.create(:domain, :name => 'be_editable.to-be-found.com')
            auth        = Authorizer.new(@user)

            collection = auth.find_collection(Domain, :permission => :view_domains)
            assert_equal [domain2, domain3], collection
            collection = auth.find_collection(Domain, :permission => :edit_domains)
            assert_equal [domain4], collection
            collection = auth.find_collection(Domain, :permission => :delete_domains)
            assert_empty collection
            collection = auth.find_collection(Domain)
            assert_equal [domain2, domain3, domain4], collection

            refute auth.can?(:view_domains, domain1, cache)
            assert auth.can?(:view_domains, domain2, cache)
            assert auth.can?(:view_domains, domain3, cache)
            refute auth.can?(:view_domains, domain4, cache)
            refute auth.can?(:edit_domains, domain1, cache)
            refute auth.can?(:edit_domains, domain2, cache)
            refute auth.can?(:edit_domains, domain3, cache)
            assert auth.can?(:edit_domains, domain4, cache)
            # filter on Domain permission does add the domain
            FactoryBot.create(:filter, :role => @role, :permissions => [permission1])
            collection = auth.find_collection(Domain)
            assert_includes collection, domain1
            assert_includes collection, domain2
            assert_includes collection, domain3
            assert_includes collection, domain4
          end

          test "for user without filter" do
            permission = Permission.find_by_name('view_domains')
            FactoryBot.create(:filter, :role => @role, :permissions => [permission])
            domain     = FactoryBot.create(:domain)
            auth       = Authorizer.new(FactoryBot.create(:user))

            result = auth.find_collection(Domain, :permission => :view_domains)
            assert_not_includes result, domain
            assert_kind_of ActiveRecord::Relation, result
            refute auth.can?(:view_domains, domain, cache)
          end

          test "caches results per permission and class" do
            permission1 = Permission.find_by_name('view_domains')
            FactoryBot.create(:filter, :on_name_starting_with_a,
              :role => @role, :permissions => [permission1])
            domain1     = FactoryBot.create(:domain, :name => 'a-domain.to-be-found.com')
            domain2     = FactoryBot.create(:domain, :name => 'x-domain.not-to-be-found.com')
            permission2 = Permission.find_by_name('view_architectures')
            architecture = FactoryBot.create(:architecture)
            FactoryBot.create(:filter, :role => @role, :permissions => [permission2])

            auth = Authorizer.new(@user)

            auth.stubs(:find_collection).returns(Domain.where(id: domain1.id)).
              times(cache ? 3 : 6)
            assert auth.can?(:view_domain, domain1, cache)
            refute auth.can?('view_domain', domain2, cache)
            assert auth.can?(:edit_domain, domain1, cache)
            refute auth.can?('edit_domain', domain2, cache)
            refute auth.can?(:view_architectures, architecture, cache) # since it's stubbed and returns domain1 only
            refute auth.can?('view_architectures', architecture, cache)
          end

          test "empty base collection set" do
            domain     = FactoryBot.create(:domain)
            permission = Permission.find_by_name('view_domains')
            FactoryBot.create(:filter, :role => @role, :permissions => [permission])
            auth = Authorizer.new(@user, :collection => [])

            refute auth.can?(:view_domains, domain, cache)
          end

          test "excluding base collection set" do
            permission = Permission.find_by_name('view_domains')
            FactoryBot.create(:filter, :on_name_starting_with_a,
              :role => @role, :permissions => [permission])
            domain1    = FactoryBot.create(:domain, :name => 'a-domain.to-be-found.com')
            domain2    = FactoryBot.create(:domain, :name => 'another-domain.to-be-found.com')
            auth       = Authorizer.new(@user, :collection => [domain2])

            refute auth.can?(:view_domains, domain1, cache)
            assert auth.can?(:view_domains, domain2, cache)
          end

          test "with Subnet subclasses" do
            permission = Permission.find_by_name('edit_subnets')
            FactoryBot.create(:filter, :role => @role, :permissions => [permission])
            subnet     = FactoryBot.create(:subnet_ipv4)
            auth       = Authorizer.new(@user)
            assert auth.can?(:edit_subnets, subnet, cache)
          end
        end
      end
    end
  end

  test "#build_scoped_search_condition(filters) for empty set" do
    auth = Authorizer.new(FactoryBot.create(:user))
    assert_raises ArgumentError do
      auth.build_scoped_search_condition([])
    end
  end

  test "#build_scoped_search_condition(filters) for one filter" do
    user = FactoryBot.create(:user)
    auth    = Authorizer.new(user)
    filters = [FactoryBot.build_stubbed(:filter, :on_name_all)]
    result  = auth.build_scoped_search_condition(filters)

    assert_equal "(((name ~ *)) AND ((organization_id ^ (#{user.organization_ids.first})) AND (location_id ^ (#{user.location_ids.first}))))", result
  end

  test "#build_scoped_search_condition(filters) for more filters" do
    user = FactoryBot.create(:user)
    auth    = Authorizer.new(user)
    filters = [FactoryBot.build_stubbed(:filter, :on_name_all), FactoryBot.build_stubbed(:filter, :on_name_starting_with_a)]
    result  = auth.build_scoped_search_condition(filters)
    assert_equal result, "(((name ~ *) OR (name ~ a*)) AND ((organization_id ^ (#{user.organization_ids.first})) AND (location_id ^ (#{user.location_ids.first}))))"
  end

  test "#build_scoped_search_condition(filters) for filter" do
    user = FactoryBot.create(:user)
    auth    = Authorizer.new(user)
    filters = [FactoryBot.build_stubbed(:filter)]
    result  = auth.build_scoped_search_condition(filters)

    assert_equal "(((organization_id ^ (#{user.organization_ids.first})) AND (location_id ^ (#{user.location_ids.first}))))", result
  end

  test "#build_scoped_search_condition(filters) for limited and unlimited filter" do
    user = FactoryBot.create(:user)
    auth    = Authorizer.new(user)
    filters = [FactoryBot.build_stubbed(:filter, :on_name_all), FactoryBot.build_stubbed(:filter)]
    result  = auth.build_scoped_search_condition(filters)

    assert_equal "(((organization_id ^ (#{user.organization_ids.first})) AND (location_id ^ (#{user.location_ids.first}))))", result
  end

  test "#build_scoped_search_condition(filters) for empty filter" do
    user = FactoryBot.create(:user)
    auth    = Authorizer.new(user)
    filters = [FactoryBot.build_stubbed(:filter, :search => nil)]
    result  = auth.build_scoped_search_condition(filters)

    assert_equal "(((organization_id ^ (#{user.organization_ids.first})) AND (location_id ^ (#{user.location_ids.first}))))", result
  end

  test "#find_collection(Host, :permission => :view_hosts) with scoped_search join returns r/w resources" do
    host       = FactoryBot.create(:host, :with_facts)
    fact       = host.fact_values.first
    permission = Permission.find_by_name('view_hosts')
    FactoryBot.create(:filter, :role => @role, :permissions => [permission],
                                :search => "facts.#{fact.name} = #{fact.value}")
    auth = Authorizer.new(@user)

    results = auth.find_collection(Host::Managed, :permission => :view_hosts)
    assert_includes results, host
    refute results.grep(host).first.readonly?
  end

  test "#find_collection(Host, :permission => :view_hosts, :joined_on: Report) for admin" do
    host       = FactoryBot.create(:host)
    report     = FactoryBot.create(:config_report, :host => host)
    @user.update_attribute(:admin, true)
    auth = Authorizer.new(@user)

    assert_includes auth.find_collection(Host::Managed, :permission => :view_hosts, :joined_on => Report), report
  end

  test "#find_collection(Host, :permission => :view_hosts, :joined_on: Report) for matching filter" do
    permission = Permission.find_by_name('view_hosts')
    FactoryBot.create(:filter, :role => @role, :permissions => [permission])
    host       = FactoryBot.create(:host)
    report     = FactoryBot.create(:config_report, :host => host)
    auth       = Authorizer.new(@user)

    assert_includes auth.find_collection(Host::Managed, :permission => :view_hosts, :joined_on => Report), report
  end

  test "#find_collection(Host, :permission => :view_hosts, :joined_on: Report) for matching limited filter with base collection set" do
    permission = Permission.find_by_name('view_hosts')
    FactoryBot.create(:filter, :role => @role, :permissions => [permission],
                                :search => 'hostgroup ~ hostgroup*')
    (host1, host2) = FactoryBot.create_pair(:host, :with_hostgroup)
    report1        = FactoryBot.create(:config_report, :host => host1)
    report2        = FactoryBot.create(:config_report, :host => host2)
    auth           = Authorizer.new(@user, :collection => [host2])

    collection = auth.find_collection(Host::Managed, :permission => :view_hosts, :joined_on => Report)
    refute_includes collection, report1
    assert_includes collection, report2
  end

  test "#find_collection(Host, :permission => :view_hosts, :joined_on: Report, :where => ..) applies where clause" do
    permission = Permission.find_by_name('view_hosts')
    FactoryBot.create(:filter, :role => @role, :permissions => [permission])
    hosts      = FactoryBot.create_pair(:host)
    report1    = FactoryBot.create(:config_report, :host => hosts.first)
    report2    = FactoryBot.create(:config_report, :host => hosts.last)
    auth       = Authorizer.new(@user)

    collection = auth.find_collection(Host::Managed, :permission => :view_hosts, :joined_on => Report,
                                      :where => {'name' => hosts.first.name})
    assert_includes collection, report1
    refute_includes collection, report2
  end

  test "#find_collection(Host::Base) works with taxonomies thanks to class name sanitization" do
    permission = Permission.find_by_name('view_hosts')
    FactoryBot.create(:filter, :role => @role, :permissions => [permission])
    auth = Authorizer.new(@user)

    assert_nothing_raised do
      auth.find_collection(Host::Base)
    end
  end

  test "#find_collection returns no results for unsupported scoped search" do
    permission = Permission.find_by_name('view_hosts')
    auth = Authorizer.new(@user)

    Filter.new(role: @role, permissions: [permission], search: 'invalid_field = raise-an-error').save(validate: false)
    assert_empty auth.find_collection(Host::Managed, permission: :view_hosts)
  end

  describe '#find_collection' do
    context 'using joined_on option' do
      test 'allows filtering on associations that do not match association class' do
        permission = Permission.find_by_name('view_hosts')
        FactoryBot.create(:host, :debian, :with_facts)
        FactoryBot.create(:filter, role: @role, permissions: [permission], search: 'os = Debian')
        authorizer = Authorizer.new(@user)
        # FactValue is referencing HostBase, but operatingsystem association is defined on Host::Managed
        # this could cause unknown association exception in Rails, we should avoid it
        assert_nothing_raised do
          authorizer.find_collection(Host, permission: :view_hosts, joined_on: FactValue).to_a
        end
        assert_operator 0, :<, authorizer.find_collection(Host, permission: :view_hosts, joined_on: FactValue).count
      end
    end

    context 'user taxonomy scoping' do
      setup do
        as_admin do
          @org1 = FactoryBot.create(:organization)
          @org2 = FactoryBot.create(:organization)
          @loc1 = FactoryBot.create(:location)
          @loc2 = FactoryBot.create(:location)
          @user_role  = FactoryBot.create(:user_user_role)
          @user       = @user_role.owner
          @role       = @user_role.role
        end
      end

      test 'user should not see resource from a different org' do
        permission = Permission.find_by_name('view_domains')
        domain = FactoryBot.create(:domain, organization_ids: [@org1.id])
        FactoryBot.create(:filter, role: @role, permissions: [permission], search: "name = #{domain.name}")

        assert_predicate (domain.organization_ids & @user.organization_ids), :empty?, 'user and domain do not share any organization'

        User.current = @user
        assert_empty ::Domain.unscoped.authorized(:view_domains)
      end

      test 'user should see resource in the same org' do
        permission = Permission.find_by_name('view_domains')
        domain = FactoryBot.create(:domain)
        FactoryBot.create(:filter, role: @role, permissions: [permission], search: "name = #{domain.name}")

        assert_predicate (domain.organization_ids & @user.organization_ids), :any?, 'user and domain share at least one organization'

        User.current = @user
        assert_equal [domain.id], ::Domain.unscoped.authorized(:view_domains).map(&:id)
      end

      test 'user should see resource in a child org' do
        permission = Permission.find_by_name('view_domains')
        child_org = FactoryBot.create(:organization)
        child_org.parent_id = @user.organization_ids.first
        child_org.save!

        domain = FactoryBot.create(:domain, organization_ids: [child_org.id])
        FactoryBot.create(:filter, role: @role, permissions: [permission], search: "name = #{domain.name}")

        assert_predicate (domain.organization_ids & @user.organization_ids), :empty?, 'user and domain do not share any organization'

        User.current = @user
        assert_equal [domain.id], ::Domain.unscoped.authorized(:view_domains).map(&:id)
      end
    end
  end
end
