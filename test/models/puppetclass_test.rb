require 'test_helper'

class PuppetclassTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)

  test "name strips leading and trailing white spaces" do
    puppet_class = Puppetclass.new :name => "   testclass   "
    assert puppet_class.save
    refute puppet_class.name.ends_with?(' ')
    refute puppet_class.name.starts_with?(' ')
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
      role = Role.where(:name => "testing_role").first_or_create
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

  context "host counting" do
    setup do
      @env = FactoryGirl.create(:environment)
      @class = FactoryGirl.create(:puppetclass)
      @parent_hg = FactoryGirl.create(:hostgroup)
      @hostgroup = FactoryGirl.create(:hostgroup, :parent => @parent_hg)
      @config_group = FactoryGirl.create(:config_group, :puppetclasses => [@class])
      @host = FactoryGirl.create(:host, :environment => @env)
    end

    test "correctly counts direct hosts" do
      @host.puppetclasses << @class
      assert_equal 1, @class.hosts_count
    end

    test "correctly counts hosts via config group" do
      @host.config_groups << @config_group
      assert_equal 1, @class.hosts_count
    end

    test "correctly counts hosts via hostgroup" do
      @hostgroup.puppetclasses << @class
      @host.update_attribute(:hostgroup_id, @hostgroup.id)
      assert_equal 1, @class.hosts_count
    end

    test "correctly counts hosts via parent hostgroup" do
      @host.update_attribute(:hostgroup_id, @hostgroup.id)
      @parent_hg.puppetclasses << @class
      assert_equal 1, @class.hosts_count
    end

    test "correctly counts hosts via hostgroup config group" do
      @host.update_attribute(:hostgroup_id, @hostgroup.id)
      @hostgroup.config_groups << @config_group
      assert_equal 1, @class.hosts_count
    end

    test "correctly counts hosts via parent hostgroup config group" do
      @host.update_attribute(:hostgroup_id, @hostgroup.id)
      @parent_hg.config_groups << @config_group
      assert_equal 1, @class.hosts_count
    end

    test "only count host once even if it has multiple connections to puppetclass" do
      @host.puppetclasses << @class
      @host.config_groups << @config_group
      @hostgroup.puppetclasses << @class
      @hostgroup.config_groups << @config_group
      @parent_hg.puppetclasses << @class
      @parent_hg.config_groups << @config_group
      @host.update_attribute(:hostgroup_id, @hostgroup.id)
      assert_equal 1, @class.hosts_count
    end
  end

  test "three levels of nested attributes still validate nested objects" do
    klass = FactoryGirl.create(:puppetclass)
    hostgroup = FactoryGirl.create(:hostgroup)
    lk = FactoryGirl.create(:variable_lookup_key, puppetclass_id: klass.id)
    attributes = {"hostgroup_ids"=>[hostgroup.id],
      "lookup_keys_attributes"=>
      {"0"=>
        { "_destroy"=>"false",
          "key"=>"hahs",
          "description"=>"",
          "key_type"=>"hash",
          "default_value"=>"{\"foo\" => \"bar\"}",
          "hidden_value"=>"0",
          "validator_type"=>"",
          "path"=>"owner\r\nfqdn\r\nhostgroup\r\nos\r\ndomain",
          "merge_overrides"=>"0",
          "lookup_values_attributes"=>{"0"=>{"match"=>"owner=sdgsd", "value"=>"{\"foo\" => \"bar\"}", "_destroy"=>"false"}},
          "id"=>lk.id
        }
      }
    }

    refute klass.update_attributes(attributes)
    assert klass.errors.messages.keys.include?(:"lookup_keys.lookup_values.value")
  end

  context "search in puppetclasses" do
    setup do
      @class = FactoryGirl.create(:puppetclass)
      @hostgroup = FactoryGirl.create(:hostgroup)
      @hostgroup.puppetclasses << @class
      @config_group = FactoryGirl.create(:config_group, :puppetclasses => [@class])
    end

    test "search for puppetclass by hostgroup" do
      assert_includes(Puppetclass.search_for("hostgroup = #{@hostgroup.to_label}"), @class)
    end

    test "search for puppetclass by config_group" do
      assert_includes(Puppetclass.search_for("config_group = #{@config_group.to_label}"), @class)
    end
  end

  it "destroys dependent puppetclass_lookup_keys" do
    puppetclass, puppetclass_lkey = puppetclasses(:nine), lookup_keys(:eight)
    assert puppetclass.destroy
    assert !PuppetclassLookupKey.exists?(puppetclass_lkey.id)
    assert_raise(ActiveRecord::RecordNotFound) { puppetclass_lkey.reload }
  end
end
