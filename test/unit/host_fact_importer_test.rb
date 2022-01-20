require File.dirname(__FILE__) + '/../test_helper'

class HostFactImporterTest < ActiveSupport::TestCase
  include FactImporterIsolation
  allow_transactions_for_any_importer

  setup do
    disable_orchestration
    User.current = users :admin
  end

  test "should import facts from json stream" do
    host = Host::Managed.new(:name => "sinn1636.lan")
    assert HostFactImporter.new(host).import_facts(read_json_fixture('facts/facts.json')['facts'])
  end

  test "should not trigger dhcp orchestration when importing facts" do
    host = FactoryBot.create(:host, :managed, :with_dhcp_orchestration, :name => "sinn1636.lan")
    host.stubs(:skip_orchestration_for_testing?).returns(false) # Explicitly enable orchestration
    Nic::Managed.any_instance.expects(:dhcp_conflict_detected?).never
    # assert HostFactImporter.new(host).import_facts(read_json_fixture('facts/facts.json')['facts'])
  end

  test "should not trigger orchestration by default" do
    refute Host.find_by_name('sinn1636.lan')
    raw = read_json_fixture('facts/facts_with_certname.json')
    host = Host.import_host(raw['name'], 'puppet')
    host.stubs(:skip_orchestration_for_testing?).returns(false) # Explicitly enable orchestration

    host.expects(:skip_orchestration!).at_least_once
    host.expects(:skip_orchestration?).at_least_once.returns(true)
    host.expects(:enable_orchestration!).at_least_once
    host.expects(:queue).never

    assert HostFactImporter.new(host).import_facts(raw['facts'])
  end

  test 'import_host does not require any' do
    host = Host.import_host('host', 'custom_type')
    assert_equal 'host', host.name
  end

  test 'import_host does downcase the name' do
    host = Host.import_host('HOST', 'custom_type')
    assert_equal 'host', host.name
  end

  test 'import_facts only needs operatingsystem and operatingsystemrelease fact' do
    host = Host.import_host('host', 'puppet')
    assert HostFactImporter.new(host).import_facts(:operatingsystemrelease => '6.7', :operatingsystem => 'CentOS')
  end

  test 'should import facts from json of a new host when certname is not specified' do
    refute Host.find_by_name('sinn1636.lan')
    raw = read_json_fixture('facts/facts.json')
    host = Host.import_host(raw['name'], 'puppet')
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    assert Host.find_by_name('sinn1636.lan')
  end

  test 'should import facts even when domain is not part of facts' do
    refute Host.find_by_name('sinn1636.lan')
    raw = read_json_fixture('facts/facts.json')
    raw.delete('domain')
    host = Host.import_host(raw['name'], 'puppet')
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    assert Host.find_by_name('sinn1636.lan')
  end

  test 'domain updated from facts' do
    host = FactoryBot.create(:host, :with_operatingsystem)
    FactoryBot.create(:domain, :name => 'foo.bar')
    assert HostFactImporter.new(host).import_facts(:domain => 'foo.bar', :operatingsystemrelease => host.operatingsystem.release, :operatingsystem => host.operatingsystem.name)
    assert_equal 'foo.bar', host.domain.to_s
  end

  test 'domain not updated from facts when ignore_facts_for_domain false' do
    domain = FactoryBot.create(:domain)
    host = FactoryBot.create(:host, :managed, :domain => domain)
    FactoryBot.create(:domain, :name => 'foo.bar')
    assert HostFactImporter.new(host).import_facts(:domain => domain.name, :operatingsystemrelease => host.operatingsystem.release, :operatingsystem => host.operatingsystem.name)
    Setting[:ignore_facts_for_domain] = true
    assert HostFactImporter.new(host).import_facts(:domain => 'foo.bar', :operatingsystemrelease => host.operatingsystem.release, :operatingsystem => host.operatingsystem.name)
    assert_equal domain.name, host.domain.name
    Setting[:ignore_facts_for_domain] =
      Setting.find_by_name('ignore_facts_for_domain').default
  end

  test 'host is created when updating domain from facts is disabled' do
    assert_difference 'Host.count' do
      Setting[:ignore_facts_for_domain] = true
      raw = read_json_fixture('facts/facts_with_certname.json')
      host = Host.import_host(raw['name'], raw['certname'])
      assert HostFactImporter.new(host).import_facts(raw['facts'])
      assert Host.find_by_name('sinn1636.lan')
      assert host.domain
      Setting[:ignore_facts_for_domain] =
        Setting.find_by_name('ignore_facts_for_domain').default
    end
  end

  test 'should downcase hostname parameter from json of a new host' do
    raw = read_json_fixture('facts/facts_with_caps.json')
    host = Host.import_host(raw['name'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    assert Host.find_by_name('sinn1636.lan')
  end

  test 'should downcase domain parameter from json of a new host' do
    raw = read_json_fixture('facts/facts_with_caps.json')
    host = Host.import_host(raw['name'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    assert_equal raw['facts']['domain'].downcase, Host.find_by_name('sinn1636.lan').facts_hash['domain']
  end

  test 'should import facts idempotently' do
    raw = read_json_fixture('facts/facts_with_caps.json')
    host = Host.import_host(raw['name'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    value_ids = Host.find_by_name('sinn1636.lan').fact_values.map(&:id)
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    assert_equal value_ids.sort, Host.find_by_name('sinn1636.lan').fact_values.map(&:id).sort
  end

  test 'should find a host by certname not fqdn when provided' do
    Host.new(:name => 'sinn1636.fail', :certname => 'sinn1636.lan.cert', :mac => 'e4:1f:13:cc:36:58').save(:validate => false)
    assert Host.find_by_name('sinn1636.fail').ip.nil?
    # hostname in the json is sinn1636.lan, so if the facts have been updated for
    # this host, it's a successful identification by certname
    raw = read_json_fixture('facts/facts_with_certname.json')
    host = Host.import_host(raw['name'], raw['certname'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    host = Host.find_by_name('sinn1636.fail')
    assert_equal '10.35.27.2', host.interfaces.find_by_identifier('br180').ip
    assert_nil host.primary_interface.ip # eth0 does not have ip address among facts
  end

  test 'should update certname when host is found by hostname and certname is provided' do
    Host.new(:name => 'sinn1636.lan', :certname => 'sinn1636.cert.fail').save(:validate => false)
    assert_equal 'sinn1636.cert.fail', Host.find_by_name('sinn1636.lan').certname
    raw = read_json_fixture('facts/facts_with_certname.json')
    host = Host.import_host(raw['name'], raw['certname'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    assert_equal 'sinn1636.lan.cert', Host.find_by_name('sinn1636.lan').certname
  end

  test 'host is created when uploading facts if setting is true' do
    assert_difference 'Host.count' do
      Setting[:create_new_host_when_facts_are_uploaded] = true
      raw = read_json_fixture('facts/facts_with_certname.json')
      host = Host.import_host(raw['name'], raw['certname'])
      assert HostFactImporter.new(host).import_facts(raw['facts'])
      assert Host.find_by_name('sinn1636.lan')
      Setting[:create_new_host_when_facts_are_uploaded] =
        Setting.find_by_name('create_new_host_when_facts_are_uploaded').default
    end
  end

  test 'host is not created when uploading facts if setting is false' do
    Setting[:create_new_host_when_facts_are_uploaded] = false
    refute Setting[:create_new_host_when_facts_are_uploaded]
    raw = read_json_fixture('facts/facts_with_certname.json')
    host = Host.import_host(raw['name'], raw['certname'])
    refute HostFactImporter.new(host).import_facts(raw['facts'])
    host = Host.find_by_name('sinn1636.lan')
    Setting[:create_new_host_when_facts_are_uploaded] =
      Setting.find_by_name('create_new_host_when_facts_are_uploaded').default
    assert_nil host
  end

  test 'host is updated when uploading facts if setting is false' do
    Host.new(:name => 'sinn1636.lan', :certname => 'sinn1636.cert.fail').save(:validate => false)
    Setting[:create_new_host_when_facts_are_uploaded] = false
    refute Setting[:create_new_host_when_facts_are_uploaded]
    raw = read_json_fixture('facts/facts_with_certname.json')
    host = Host.import_host(raw['name'], raw['certname'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])
  end

  test 'host taxonomies are set to a default when uploading facts' do
    Setting[:create_new_host_when_facts_are_uploaded] = true
    Setting[:default_location] = taxonomies(:location1).title
    Setting[:default_organization] = taxonomies(:organization1).title
    raw = read_json_fixture('facts/facts.json')
    host = Host.import_host(raw['name'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])

    assert_equal Setting[:default_location],     Host.find_by_name('sinn1636.lan').location.title
    assert_equal Setting[:default_organization], Host.find_by_name('sinn1636.lan').organization.title
  end

  test 'host taxonomies are set to setting[taxonomy_fact] if it exists' do
    Setting[:create_new_host_when_facts_are_uploaded] = true
    Setting[:location_fact] = "foreman_location"
    Setting[:organization_fact] = "foreman_organization"

    raw = read_json_fixture('facts/facts.json')
    raw['facts']['foreman_location']     = 'Location 2'
    raw['facts']['foreman_organization'] = 'Organization 2'
    host = Host.import_host(raw['name'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])

    assert_equal 'Location 2',     Host.find_by_name('sinn1636.lan').location.title
    assert_equal 'Organization 2', Host.find_by_name('sinn1636.lan').organization.title
  end

  test 'default taxonomies are not assigned to hosts with taxonomies' do
    Setting[:default_location] = taxonomies(:location1).title
    raw = read_json_fixture('facts/facts.json')
    host = Host.import_host(raw['name'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    host = Host.find_by_name('sinn1636.lan')
    host.update_attribute(:location, taxonomies(:location2))
    HostFactImporter.new(host).import_facts(raw['facts'])
    host.reload

    assert_equal taxonomies(:location2), host.location
  end

  test 'taxonomies from facts override already existing taxonomies in hosts' do
    Setting[:create_new_host_when_facts_are_uploaded] = true
    Setting[:location_fact] = "foreman_location"

    raw = read_json_fixture('facts/facts.json')
    raw['facts']['foreman_location'] = 'Location 2'
    host = Host.import_host(raw['name'])
    assert HostFactImporter.new(host).import_facts(raw['facts'])

    host = Host.find_by_name('sinn1636.lan')
    host.update_attribute(:location, taxonomies(:location1))
    HostFactImporter.new(host).import_facts(raw['facts'])
    host.reload

    assert_equal taxonomies(:location2), host.location
  end

  test 'comment updated from facts when present' do
    host = Host.import_host('host')
    assert HostFactImporter.new(host).import_facts(foreman_comment: 'new comment', operatingsystemrelease: '6.7', operatingsystem: 'CentOS')
    assert_equal 'new comment', host.comment
  end

  test 'operatingsystem updated from facts' do
    host = Host.import_host('host')
    assert HostFactImporter.new(host).import_facts(:operatingsystemrelease => '6.7', :operatingsystem => 'CentOS')
    assert_equal 'CentOS 6.7', host.operatingsystem.to_s
  end

  test 'operatingsystem from facts resets medium if medium is for different OS' do
    os1 = FactoryBot.create(:operatingsystem, :with_media)
    os2 = FactoryBot.create(:operatingsystem)
    medium = os1.media.first
    host = FactoryBot.create(:host, :operatingsystem => os1, :medium => medium)
    HostFactImporter.new(host).import_facts(:operatingsystem => os2.name, :operatingsystemrelease => os2.major.to_s)

    assert_equal host.operatingsystem, os2
    assert_nil host.medium
  end

  test 'operatingsystem from facts keeps medium if medium supports OS' do
    os1 = FactoryBot.create(:operatingsystem, :with_media)
    os2 = FactoryBot.create(:operatingsystem)
    medium = os1.media.first
    medium.operatingsystems << os2

    host = FactoryBot.create(:host, :operatingsystem => os1, :medium => medium)
    HostFactImporter.new(host).import_facts(:operatingsystem => os2.name, :operatingsystemrelease => os2.major.to_s)

    assert_equal host.operatingsystem, os2
    assert_equal host.medium, medium
  end

  test 'operatingsystem not updated from facts when ignore_facts_for_operatingsystem false' do
    host = Host.import_host('host')
    assert HostFactImporter.new(host).import_facts(:operatingsystemrelease => '6.7', :operatingsystem => 'CentOS')
    Setting[:ignore_facts_for_operatingsystem] = true
    assert HostFactImporter.new(host).import_facts(:operatingsystemrelease => '6.8', :operatingsystem => 'CentOS')
    assert_equal 'CentOS 6.7', host.operatingsystem.to_s
    Setting[:ignore_facts_for_operatingsystem] =
      Setting.find_by_name('ignore_facts_for_operatingsystem').default
  end

  test 'host is created when updating operatingsystem from facts is disabled' do
    assert_difference 'Host.count' do
      Setting[:ignore_facts_for_operatingsystem] = true
      raw = read_json_fixture('facts/facts_with_certname.json')
      host = Host.import_host(raw['name'], raw['certname'])
      assert HostFactImporter.new(host).import_facts(raw['facts'])
      assert Host.find_by_name('sinn1636.lan')
      assert host.operatingsystem
      Setting[:ignore_facts_for_operatingsystem] =
        Setting.find_by_name('ignore_facts_for_operatingsystem').default
    end
  end

  test 'host hostgroup updated from facts' do
    Setting[:update_hostgroup_from_facts] = true

    raw = read_json_fixture('facts/facts.json')
    raw['facts']['foreman_hostgroup'] = 'base'
    hostgroup = FactoryBot.create(:hostgroup, :name => 'base')
    host = FactoryBot.create(:host, :hostgroup => FactoryBot.create(:hostgroup, :name => 'test'))
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    host.reload
    assert_equal hostgroup, host.hostgroup
  end

  test 'host hostgroup not updated from facts' do
    Setting[:update_hostgroup_from_facts] = false

    raw = read_json_fixture('facts/facts.json')
    raw['facts']['foreman_hostgroup'] = 'base'
    FactoryBot.create(:hostgroup, :name => 'base')
    hostgroup = FactoryBot.create(:hostgroup, :name => 'test')
    host = FactoryBot.create(:host, :hostgroup => hostgroup)
    assert HostFactImporter.new(host).import_facts(raw['facts'])
    host.reload
    assert_equal hostgroup, host.hostgroup
  end

  describe 'a host with primary interface on a bond' do
    let(:raw_facts) { read_json_fixture('facts/facts_with_primary_interface_bond.json').merge(_type: 'puppet') }
    let(:hostname) { 'host01.example.com' }
    let(:certname) { 'host01.example.com' }

    setup do
      Resolv::DNS.any_instance.stubs(:getnames).returns([])
    end

    it 'sets bond0 as primary interface' do
      host = Host.import_host(hostname, certname)
      assert HostFactImporter.new(host).import_facts(raw_facts)
      assert_equal 'Nic::Bond', host.primary_interface.type
    end
  end

  describe 'a host with primary interface on a bridge on a vlan on a bond via facter 3' do
    let(:raw_facts) { read_json_fixture('facts/primary_bridge_vlan_bond.json').merge(_type: 'puppet') }
    let(:hostname) { 'server-42.example.com' }
    let(:certname) { 'server-42.example.com' }

    setup do
      Resolv::DNS.any_instance.expects(:getnames).never
    end

    it 'sets bond0 as primary interface' do
      host = Host.import_host(hostname, certname)
      assert HostFactImporter.new(host).import_facts(raw_facts)
      assert_equal 'br_customer', host.primary_interface.identifier
    end
  end
end
