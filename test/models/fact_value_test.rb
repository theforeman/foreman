require 'test_helper'

class FactValueTest < ActiveSupport::TestCase
  def setup
    as_admin do
      @host = FactoryBot.create(:host)
      @fact_name = FactName.create(:name => "my_facting_name")
      @fact_value = FactValue.create(:value => "some value", :host => @host, :fact_name => @fact_name)
      @child_name = FactName.create(:name => 'my_facting_name::child', :parent => @fact_name)
      @child_value = FactValue.create(:value => 'child value', :host => @host, :fact_name => @child_name)
      [@fact_name, @fact_value, @child_name, @child_value].map(&:save)
    end
  end

  test ".build_facts_hash returns a hash with host name" do
    hash = { @host.to_s => { @fact_name.name => @fact_value.value } }
    assert_equal hash, FactValue.build_facts_hash([@fact_value])
  end

  test "should return the count of each fact" do
    h = [{:label => "some value", :data => 1}]
    assert_equal h, FactValue.count_each("my_facting_name")

    # Now creating a new fact value
    @other_host = FactoryBot.create(:host)
    FactValue.create(:value => "some value", :host => @other_host, :fact_name => @fact_name)
    h = [{:label => "some value", :data => 2}]
    assert_equal h, FactValue.count_each("my_facting_name")
  end

  test 'origin comes from fact_name' do
    assert_equal @fact_value.origin, @fact_name.origin
  end

  test "should fail validation when the host already has a fact with the same name" do
    assert !FactValue.new(:value => "some value", :host => @host, :fact_name => @fact_name).valid?
  end

  test '.root_only scope returns only roots' do
    result = FactValue.root_only
    assert_includes result, @fact_value
    assert_not_include result, @child_value
  end

  test '.with_fact_parent_id scope returns only children for given id' do
    result = FactValue.with_fact_parent_id(@fact_name.id)
    assert_equal [@child_value], result

    result = FactValue.with_fact_parent_id(@child_name.id)
    assert_equal [], result
  end

  test "should return search results if search free text is fact name" do
    FactoryBot.create(:fact_value, :value => '2.6.9', :host => FactoryBot.create(:host),
                       :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))
    results = FactValue.search_for('kernelversion')
    assert_equal 1, results.count
    assert_equal 'kernelversion', results.first.name
  end

  test "should return search results for name = fact name" do
    FactoryBot.create(:fact_value, :value => '2.6.9', :host => FactoryBot.create(:host),
                       :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))
    results = FactValue.search_for('name = kernelversion')
    assert_equal 1, results.count
    assert_equal 'kernelversion', results.first.name
  end

  test 'should return search results for host = fqdn' do
    host = FactoryBot.create(:host)
    FactoryBot.create(:fact_value, :value => '2.6.9', :host => host,
                       :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))
    results = FactValue.search_for("host = #{host.fqdn}")
    refute_empty results
  end

  test 'should return empty search results for ILIKE operator on host' do
    results = FactValue.search_for("host ~ abc")
    assert_empty results
  end

  test 'should return search results for ILIKE operator on hostgroup' do
    host = FactoryBot.create(:host, :hostgroup => FactoryBot.create(:hostgroup, :name => 'samplehgp'))
    FactoryBot.create(:fact_value, :value => '2.6.9', :host => host,
                       :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))
    results = FactValue.search_for("host.hostgroup ~ ampl")
    assert_equal 1, results.count
  end

  test 'should return search results for host.hostgroup = name' do
    host = FactoryBot.create(:host, :with_hostgroup)
    hostgroup = host.hostgroup.to_label
    FactoryBot.create(:fact_value, :value => '2.6.9', :host => host,
                       :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))
    results = FactValue.search_for("host.hostgroup = #{hostgroup}")
    refute_empty results
  end

  test 'should return empty search results for host with no facts' do
    host = FactoryBot.create(:host)
    results = FactValue.search_for("host = #{host.fqdn}")
    assert_empty results
  end

  test 'numeric searches should use numeric comparsion' do
    host = FactoryBot.create(:host)
    FactoryBot.create(:fact_value, :value => '64498', :host => host,
                       :fact_name => FactoryBot.create(:fact_name, :name => 'memory_mb'))
    results = FactValue.search_for("facts.memory_mb > 112889")
    assert_empty results
    results = FactValue.search_for("facts.memory_mb > 6544")
    refute_empty results
    results = FactValue.search_for("value > 112889")
    assert_empty results
    results = FactValue.search_for("value > 6544")
    refute_empty results
    results = FactValue.search_for("name = memory_mb AND value > 6544")
    refute_empty results
  end

  test "search by fact name is not vulnerable to SQL injection in name" do
    query = "facts.a'b = c or facts.#{@fact_name.name} = \"#{@fact_value.value}\""
    assert_equal [@fact_value], FactValue.search_for(query)
  end

  test "search by fact name is not vulnerable to SQL injection in value" do
    query = "facts.a = \"a'b\" or facts.#{@fact_name.name} = \"#{@fact_value.value}\""
    assert_equal [@fact_value], FactValue.search_for(query)
  end

  describe '.my_facts' do
    let(:target_host) { FactoryBot.create(:host, :with_hostgroup, :with_facts) }
    let(:other_host) { FactoryBot.create(:host, :with_hostgroup, :with_facts) }

    test 'returns all facts for admin' do
      as_admin do
        assert_empty (target_host.fact_values + other_host.fact_values).map(&:id) - FactValue.my_facts.map(&:id)
      end
    end

    test 'returns visible facts for unlimited user' do
      user_role = FactoryBot.create(:user_user_role)
      FactoryBot.create(:filter, :role => user_role.role,
                         :permissions => Permission.unscoped.where(:name => 'view_hosts'),
                         :unlimited => true)
      target_host.organization = user_role.owner.organizations.first
      target_host.location = user_role.owner.locations.first
      other_host.organization = user_role.owner.organizations.first
      other_host.location = user_role.owner.locations.first
      as_user user_role.owner do
        assert_empty (target_host.fact_values + other_host.fact_values).map(&:id) - FactValue.my_facts.map(&:id)
      end
    end

    test 'returns visible facts for filtered user' do
      user_role = FactoryBot.create(:user_user_role)
      FactoryBot.create(:filter, :role => user_role.role, :permissions => Permission.where(:name => 'view_hosts'), :search => "hostgroup_id = #{target_host.hostgroup_id}")
      as_user user_role.owner do
        assert_equal target_host.fact_values.map(&:id).sort, FactValue.my_facts.map(&:id).sort
      end
    end

    context 'taxonomies' do
      setup do
        @orgs = FactoryBot.create_pair(:organization)
        @locs = FactoryBot.create_pair(:location)
      end

      context 'limited view permissions' do
        setup do
          setup_user('view', 'hosts',
            "hostgroup_id = #{target_host.hostgroup_id}")

          as_admin do
            target_host.location = @locs.last
            target_host.organization = @orgs.last
            target_host.save

            hostgroup = Hostgroup.find(target_host.hostgroup_id)
            hostgroup.organizations = [@orgs.last]
            hostgroup.locations = [@locs.last]
            hostgroup.save
          end
        end

        test 'user cannot view host taxonomy, my_facts is empty' do
          users(:one).locations = [@locs.first]
          users(:one).organizations = [@orgs.first]

          assert_equal [], FactValue.my_facts.map(&:id).sort
        end

        test 'user can view host taxonomy, my_facts contains host facts' do
          users(:one).locations = [@locs.last]
          users(:one).organizations = [@orgs.last]

          assert_equal target_host.fact_values.map(&:id).sort,
            FactValue.my_facts.map(&:id).sort
        end
      end

      test "only return facts from host in admin's currently selected taxonomy" do
        user = as_admin { FactoryBot.create(:user, :admin) }
        target_host.update(:location => @locs.last, :organization => @orgs.last)

        as_user user do
          in_taxonomy(@orgs.first) do
            in_taxonomy(@locs.first) do
              refute_includes FactValue.my_facts, target_host.fact_values.first
            end
          end

          in_taxonomy(@orgs.last) do
            in_taxonomy(@locs.last) do
              assert_includes FactValue.my_facts, target_host.fact_values.first
            end
          end
        end
      end
    end
  end
end
