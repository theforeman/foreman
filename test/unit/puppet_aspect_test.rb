require 'test_helper'

class PuppetAspectTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = users :admin
    Setting[:token_duration] = 0
    Foreman::Model::EC2.any_instance.stubs(:image_exists?).returns(true)
  end

  context "location or organizations are not enabled" do
    before do
      SETTINGS[:locations_enabled] = false
      SETTINGS[:organizations_enabled] = false
    end

    after do
      SETTINGS[:locations_enabled] = true
      SETTINGS[:organizations_enabled] = true
    end
    test "handle_ca must not perform actions when the manage_puppetca setting is false" do
      puppet_aspect = FactoryGirl.create(:puppet_aspect, :with_puppet_ca)
      h = FactoryGirl.create(:host, :with_puppet, :puppet_aspect => puppet_aspect)
      puppet_aspect.host = h
      Setting[:manage_puppetca] = false
      h.expects(:initialize_puppetca).never
      h.expects(:setAutosign).never
      assert h.puppet_aspect.handle_ca
    end

    test "handle_ca must not perform actions when no Puppet CA proxy is associated even if associated with hostgroup" do
      hostgroup = FactoryGirl.create(:hostgroup, :with_puppet_orchestration)
      puppet_aspect = FactoryGirl.create(:puppet_aspect, :with_puppet_ca)
      h = FactoryGirl.create(:host, :with_puppet_orchestration, :puppet_aspect => puppet_aspect, :hostgroup => hostgroup)
      puppet_aspect.host = h
      Setting[:manage_puppetca] = true
      assert h.puppet_aspect.puppet_proxy.present?
      assert h.puppet_aspect.puppetca?

      h.puppet_aspect.puppet_proxy_id = h.puppet_aspect.puppet_ca_proxy_id = nil
      h.save

      refute h.puppet_aspect.puppetca?

      h.expects(:initialize_puppetca).never
      assert h.puppet_aspect.handle_ca
    end

    test "handle_ca must not perform actions when no Puppet CA proxy is associated" do
      h = FactoryGirl.create(:host, :with_puppet)
      Setting[:manage_puppetca] = true
      refute h.puppet_aspect.puppetca?
      h.expects(:initialize_puppetca).never
      assert h.puppet_aspect.handle_ca
    end

    test "handle_ca must call initialize, delete cert and add autosign methods" do
      puppet_aspect = FactoryGirl.create(:puppet_aspect, :with_puppet_ca)
      h = FactoryGirl.create(:host, :with_puppet_orchestration, :puppet_aspect => puppet_aspect)
      puppet_aspect.host = h
      Setting[:manage_puppetca] = true
      assert h.puppet_aspect.puppetca?
      h.expects(:initialize_puppetca).returns(true)
      h.expects(:delCertificate).returns(true)
      h.expects(:setAutosign).returns(true)
      assert h.puppet_aspect.handle_ca
    end

    test "if the user toggles off the use_uuid_for_certificates option, revoke the UUID and autosign the hostname" do
      puppet_aspect = FactoryGirl.create(:puppet_aspect, :with_puppet_ca)
      h = FactoryGirl.create(:host, :with_puppet_orchestration, :puppet_aspect => puppet_aspect)
      puppet_aspect.host = h
      Setting[:manage_puppetca] = true
      assert h.puppet_aspect.puppetca?

      Setting[:use_uuid_for_certificates] = false
      some_uuid = Foreman.uuid
      h.certname = some_uuid

      h.expects(:initialize_puppetca).returns(true)
      mock_puppetca = Object.new
      mock_puppetca.expects(:del_certificate).with(some_uuid).returns(true)
      mock_puppetca.expects(:set_autosign).with(h.name).returns(true)
      h.instance_variable_set("@puppetca", mock_puppetca)

      assert h.puppet_aspect.handle_ca
      assert_equal h.certname, h.name
    end

    test "if the user changes a hostname in non-use_uuid_for_cetificates mode, revoke the old hostname and autosign the new hostname" do
      Setting[:use_uuid_for_certificates] = false
      Setting[:manage_puppetca] = true

      puppet_aspect = FactoryGirl.create(:puppet_aspect, :with_puppet_ca)
      h = FactoryGirl.create(:host, :with_puppet_orchestration, :puppet_aspect => puppet_aspect)
      puppet_aspect.host = h
      assert h.puppet_aspect.puppetca?

      old_name = 'oldhostname'
      h.certname = old_name

      h.expects(:initialize_puppetca).returns(true)
      mock_puppetca = Object.new
      mock_puppetca.expects(:del_certificate).with(old_name).returns(true)
      mock_puppetca.expects(:set_autosign).with(h.name).returns(true)
      h.instance_variable_set("@puppetca", mock_puppetca)

      assert h.puppet_aspect.handle_ca
      assert_equal h.certname, h.name
    end

    test "should update puppet_proxy_id to the id of the validated proxy" do
      sp = smart_proxies(:puppetmaster)
      raw = parse_json_fixture('/facts_with_caps.json')
      Host.import_host_and_facts(raw['name'], raw['facts'], nil, sp.id)
      assert_equal sp.id, Host.find_by_name('sinn1636.lan').puppet_aspect.puppet_proxy_id
    end

    test "shouldn't update puppet_proxy_id if it has been set" do
      Host.new(:name => 'sinn1636.lan', :puppet_proxy_id => smart_proxies(:puppetmaster).id).save(:validate => false)
      sp = smart_proxies(:puppetmaster)
      raw = parse_json_fixture('/facts_with_certname.json')
      assert Host.import_host_and_facts(raw['name'], raw['facts'], nil, sp.id)
      assert_equal smart_proxies(:puppetmaster).id, Host.find_by_name('sinn1636.lan').puppet_aspect.puppet_proxy_id
    end

    test "host puppet classes must belong to the host environment" do
      h = FactoryGirl.create(:host, :with_puppet)

      pc = puppetclasses(:three)
      h.puppetclasses << pc
      assert !h.puppet_aspect.environment.puppetclasses.map(&:id).include?(pc.id)
      assert !h.valid?
      assert_equal ["#{pc} does not belong to the #{h.puppet_aspect.environment} environment"], h.errors[:puppetclasses]
    end

    test "when changing host environment, its puppet classes should be verified" do
      pa = FactoryGirl.create(:puppet_aspect, :environment => environments(:production))
      h = FactoryGirl.create(:host, :puppet_aspect => pa)
      pc = puppetclasses(:one)
      h.puppetclasses << pc
      assert h.save
      h.puppet_aspect.environment = environments(:testing)
      assert !h.save
      assert_equal ["#{pc} does not belong to the #{h.puppet_aspect.environment} environment"], h.errors[:puppetclasses]
    end
  end

  test "should return all classes for environment only" do
    pa = FactoryGirl.create(:puppet_aspect, :environment => environments(:production))
    host = FactoryGirl.create(:host,
                              :puppet_aspect => pa,
                              :location => taxonomies(:location1),
                              :organization => taxonomies(:organization1),
                              :config_groups => [config_groups(:one), config_groups(:two)],
                              :puppetclasses => [puppetclasses(:one)])
    all_classes = host.puppet_aspect.classes
    # four classes in config groups plus one manually added
    assert_equal 5, all_classes.count
    assert_equal ['base', 'chkmk', 'nagios', 'pam', 'auth'].sort, all_classes.map(&:name).sort
    assert_equal all_classes, host.puppet_aspect.all_puppetclasses
  end

  test "parent_classes should return parent_classes if host has hostgroup and environment are the same" do
    hostgroup        = FactoryGirl.create(:hostgroup, :with_puppetclass)
    pa               = FactoryGirl.create(:puppet_aspect, :environment => hostgroup.environment)
    host             = FactoryGirl.create(:host, :hostgroup => hostgroup, :puppet_aspect => pa)
    assert host.hostgroup
    refute_empty host.puppet_aspect.parent_classes
    assert_equal host.puppet_aspect.parent_classes, host.hostgroup.classes
  end

  test "parent_classes should not return parent classes that do not match environment" do
    # one class in the right env, one in a different env
    pclass1 = FactoryGirl.create(:puppetclass, :environments => [environments(:testing), environments(:production)])
    pclass2 = FactoryGirl.create(:puppetclass, :environments => [environments(:production)])
    hostgroup        = FactoryGirl.create(:hostgroup, :puppetclasses => [pclass1, pclass2], :environment => environments(:testing))
    pa               = FactoryGirl.create(:puppet_aspect, :environment => environments(:production))
    host             = FactoryGirl.create(:host, :hostgroup => hostgroup, :puppet_aspect => pa)
    assert host.hostgroup
    refute_empty host.puppet_aspect.parent_classes
    refute_equal host.puppet_aspect.environment, host.hostgroup.environment
    refute_equal host.puppet_aspect.parent_classes, host.hostgroup.classes
  end

  test "parent_classes should return empty array if host does not have hostgroup" do
    host = FactoryGirl.create(:host, :with_puppet)
    assert_nil host.hostgroup
    assert_empty host.puppet_aspect.parent_classes
  end

  test "individual puppetclasses added to host (that can be removed) does not include classes that are included by config group" do
    host   = FactoryGirl.create(:host, :with_config_group)
    pclass = FactoryGirl.create(:puppetclass, :environments => [host.puppet_aspect.environment])
    host.puppetclasses << pclass
    # not sure why, but .classes and .puppetclasses don't return the same thing here...
    assert_equal (host.config_groups.first.classes + [pclass]).map(&:name).sort, host.puppet_aspect.classes.map(&:name).sort
    assert_equal [pclass.name], host.puppet_aspect.individual_puppetclasses.map(&:name)
  end

  test "available_puppetclasses should return all if no environment" do
    host = FactoryGirl.create(:host, :with_puppet)
    host.puppet_aspect.update_attribute(:environment_id, nil)
    assert_equal Puppetclass.scoped, host.puppet_aspect.available_puppetclasses
  end

  test "available_puppetclasses should return environment-specific classes" do
    host = FactoryGirl.create(:host, :with_puppet)
    refute_equal Puppetclass.scoped, host.puppet_aspect.available_puppetclasses
    assert_equal host.puppet_aspect.environment.puppetclasses.sort, host.puppet_aspect.available_puppetclasses.sort
  end

  test "available_puppetclasses should return environment-specific classes (and that are NOT already inherited by parent)" do
    hostgroup        = FactoryGirl.create(:hostgroup, :with_puppetclass)
    pa               = FactoryGirl.create(:puppet_aspect, :environment => hostgroup.environment)
    host             = FactoryGirl.create(:host, :hostgroup => hostgroup, :puppet_aspect => pa)
    refute_equal Puppetclass.scoped, host.puppet_aspect.available_puppetclasses
    refute_equal host.puppet_aspect.environment.puppetclasses.sort, host.puppet_aspect.available_puppetclasses.sort
    assert_equal (host.puppet_aspect.environment.puppetclasses - host.puppet_aspect.parent_classes).sort, host.puppet_aspect.available_puppetclasses.sort
  end

  test "#info ENC YAML uses all_puppetclasses for non-parameterized output" do
    Setting[:Parametrized_Classes_in_ENC] = false
    host = FactoryGirl.create(:host, :with_puppetclass)
    enc = host.info
    assert_kind_of Hash, enc
    assert_equal [host.host_classes.first.puppetclass.name], enc['classes']
  end

  test "#info ENC YAML omits environment if not set" do
    host = FactoryGirl.build(:host, :with_puppet)
    host.puppet_aspect.environment = nil
    enc = host.info
    refute_includes enc.keys, 'environment'
  end

  private

  def parse_json_fixture(relative_path)
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + relative_path)))
  end
end
