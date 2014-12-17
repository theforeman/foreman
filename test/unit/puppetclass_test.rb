require 'test_helper'

class PuppetclassTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test "name can't be blank" do
    puppet_class = Puppetclass.new
    assert !puppet_class.save
  end

  test "name strips leading and trailing white spaces" do
    puppet_class = Puppetclass.new :name => "   testclass   "
    assert puppet_class.save
    refute puppet_class.name.ends_with?(' ')
    refute puppet_class.name.starts_with?(' ')
  end

  test "name must be unique" do
    puppet_class = Puppetclass.new :name => "testclass"
    assert puppet_class.save

    other_puppet_class = Puppetclass.new :name => "testclass"
    assert !other_puppet_class.save
  end

  test "looking for a nonexistent host returns no puppetclasses" do
    assert_equal [], Puppetclass.search_for("host = imaginaryhost.nodomain.what")
  end

  test "user with create external_variables permission can create smart variable for puppetclass" do
    @one = users(:one)
    # add permission for user :one
    as_admin do
      filter1 = FactoryGirl.build(:filter)
      filter1.permissions = Permission.where(:name => ['create_external_variables'])
      filter2 = FactoryGirl.build(:filter)
      filter2.permissions = Permission.where(:name => ['edit_puppetclasses'])
      role = Role.find_or_create_by(:name => "testing_role")
      role.filters = [ filter1, filter2 ]
      role.save!
      filter1.role = role
      filter1.save!
      filter2.role = role
      filter2.save!
      @one.roles = [ role ]
      @one.save!
    end
    as_user :one do
      nested_lookup_key_params = {:new_1372154591368 => {:key=>"test_param", :key_type=>"string", :default_value => "7777", :path =>"fqdn\r\nhostgroup\r\nos\r\ndomain"}}
      assert Puppetclass.first.update_attributes(:lookup_keys_attributes => nested_lookup_key_params)
    end
  end

  test "create puppetclass with smart variable as nested attribute" do
    as_admin do
      puppetclass = Puppetclass.new(:name => "PuppetclassWithSmartVariable", :lookup_keys_attributes => {"new_1372154591368" => {:key => 'smart_variable1'}})
      assert puppetclass.save
      assert_equal Puppetclass.unscoped.last.id, LookupKey.unscoped.last.puppetclass_id
    end
  end

  test "Puppetclass singularize from custom inflection" do
    assert_equal "Puppetclass", "Puppetclass".singularize
    assert_equal "Puppetclass", "Puppetclasses".singularize
    assert_equal "puppetclass", "puppetclass".singularize
    assert_equal "puppetclass", "puppetclasses".singularize
  end

  test "Puppetclass classify from custom inflection" do
    assert_equal "Puppetclass", "Puppetclass".classify
    assert_equal "Puppetclass", "Puppetclasses".classify
    assert_equal "Puppetclass", "puppetclass".classify
    assert_equal "Puppetclass", "puppetclasses".classify
  end

  context 'host counter updates on all possible class inheritance' do
    setup do
      @class = FactoryGirl.create(:puppetclass)
      @host = FactoryGirl.create(:host)
      @hostgroup = FactoryGirl.create(:hostgroup)
      @another_hostgroup = FactoryGirl.create(:hostgroup)
      @config_group = FactoryGirl.create(:config_group)
    end

    def check_host_hostgroup
      assert_difference('@class.total_hosts') do
        @host.update_attribute(:hostgroup, @hostgroup)
        @class.reload
      end
      assert_difference('@class.total_hosts', -1) do
        @host.update_attribute(:hostgroup, nil)
        @class.reload
      end
      assert_difference('@class.total_hosts') do
        @hostgroup.hosts << @host
        @class.reload
      end
      assert_difference('@class.total_hosts', -1) do
        @hostgroup.hosts.delete(@host)
        @class.reload
      end
    end

    def check_object_class(obj)
      assert_difference('@class.total_hosts') do
        obj.puppetclasses << @class
        @class.reload
      end
      assert_difference('@class.total_hosts', -1) do
        obj.puppetclasses.delete(@class)
        @class.reload
      end
      assert_difference('@class.total_hosts') do
        @class.send("#{obj.class.table_name}") << obj
        @class.reload
      end
      assert_difference('@class.total_hosts', -1) do
        @class.send("#{obj.class.table_name}").delete(obj)
        @class.reload
      end
    end

    def check_object_config_group(obj)
      assert_difference('@class.total_hosts') do
        obj.config_groups << @config_group
        @class.reload
      end
      assert_difference('@class.total_hosts', -1) do
        obj.config_groups.delete(@config_group)
        @class.reload
      end
    end

    it 'on direct assignment to host' do
      check_object_class(@host)
    end

    # hostgroup-related

    it 'class on hostgroup, adding host to hostgroup' do
      @hostgroup.puppetclasses << @class
      check_host_hostgroup
    end

    it 'host in hostgroup, adding class to hostgroup' do
      @host.update_attribute(:hostgroup, @hostgroup)
      check_object_class(@hostgroup)
    end

    it 'class on hostgroup parent, adding host to hostgroup' do
      @another_hostgroup.puppetclasses << @class
      @hostgroup.update_attribute(:parent, @another_hostgroup)
      check_host_hostgroup
    end

    it 'hostgroup ancestry change' do
      @another_hostgroup.puppetclasses << @class
      @host.update_attribute(:hostgroup, @hostgroup)
      assert_difference('@class.total_hosts') do
        @hostgroup.update_attribute(:parent, @another_hostgroup)
        @class.reload
      end
      assert_difference('@class.total_hosts', -1) do
        @hostgroup.update_attribute(:parent, nil)
        @class.reload
      end
    end

    it 'host in hostgroup, adding class to hostgroup parent' do
      @hostgroup.update_attribute(:parent, @another_hostgroup)
      @host.update_attribute(:hostgroup, @hostgroup)
      check_object_class(@another_hostgroup)
    end

    # config_group related
    it 'class on config_group, adding host to config_group' do
      @config_group.puppetclasses << @class
      check_object_config_group(@host)
    end

    it 'host in config_group, adding class to config_group' do
      @host.config_groups << @config_group
      check_object_class(@config_group)
    end

    it 'class on config_group, hostgroup in config_group, adding host to hostgroup' do
      @config_group.puppetclasses << @class
      @hostgroup.config_groups << @config_group
      check_host_hostgroup
    end

    it 'host in hostgroup, hostgroup in config_group, adding class to config_group' do
      @hostgroup.config_groups << @config_group
      @host.update_attribute(:hostgroup, @hostgroup)
      check_object_class(@config_group)
    end

    it 'class on config_group, host in hostgroup, adding hostgroup to config_group' do
      @config_group.puppetclasses << @class
      @host.update_attribute(:hostgroup, @hostgroup)
      check_object_config_group(@hostgroup)
    end
  end

  test 'changes in total_hosts are not audited' do
    puppetclass = FactoryGirl.create(:puppetclass)
    host = FactoryGirl.create(:host)
    assert_difference('Audit.count') do
      host.puppetclasses << puppetclass
    end
  end

  context "all_hostgroups should show hostgroups and their descendants" do
    setup do
      @class = FactoryGirl.create(:puppetclass)
      @hg1 = FactoryGirl.create(:hostgroup)
      @hg2 = FactoryGirl.create(:hostgroup, :parent_id => @hg1.id)
      @hg3 = FactoryGirl.create(:hostgroup, :parent_id => @hg2.id)
      @config_group = FactoryGirl.create(:config_group)
      @hg1.config_groups << @config_group
    end

    it "when added directly" do
      assert_difference('@class.all_hostgroups.count', 3) do
        @class.hostgroups << @hg1
      end
    end

    it "when added directly and called without descendants" do
      assert_difference('@class.all_hostgroups(false).count', 1) do
        @class.hostgroups << @hg1
      end
    end

    it "when added via config group" do
      assert_difference('@class.all_hostgroups.count', 3) do
        @class.config_groups << @config_group
      end
    end

    it "when added directly and called without descendants" do
      assert_difference('@class.all_hostgroups(false).count', 1) do
        @class.config_groups << @config_group
      end
    end
  end
end
