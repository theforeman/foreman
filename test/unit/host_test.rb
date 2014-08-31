require 'test_helper'

class HostTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = users :admin
    Setting[:token_duration] = 0
  end

  test "should not save without a hostname" do
    host = Host.new
    host.valid?
    assert host.errors[:name].include?("can't be blank")
  end

  test "should not save with invalid hostname" do
    host = Host.new :name => "invalid_hostname"
    host.valid?
    assert_equal "is invalid", host.errors[:name].first
  end

  test "should not save hostname with periods in shortname" do
    host = Host.new :name => "my.host", :domain => Domain.find_or_create_by_name("mydomain.net"), :managed => true
    host.valid?
    assert_equal "must not include periods", host.errors[:name].first
  end

  test "should make hostname lowercase" do
    host = Host.new :name => "MYHOST", :domain => Domain.find_or_create_by_name("mydomain.net")
    host.valid?
    assert_equal "myhost.mydomain.net", host.name
  end

  test "should update name when domain is changed" do
    host = hosts(:one)
    host.domain_name = "yourdomain.net"
    host.save!
    assert_equal "my5name.yourdomain.net", host.name
  end

  test "should fix mac address hyphens" do
    host = Host.create :name => "myhost", :mac => "aa-bb-cc-dd-ee-ff"
    assert_equal "aa:bb:cc:dd:ee:ff", host.mac
  end

  test "should fix mac address" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff"
    assert_equal "aa:bb:cc:dd:ee:ff", host.mac
  end

  test "should keep valid mac address" do
    host = Host.create :name => "myhost", :mac => "aa:bb:cc:dd:ee:ff"
    assert_equal "aa:bb:cc:dd:ee:ff", host.mac
  end

  test "should fix 64-bit mac address hyphens" do
    host = Host.create :name => "myhost", :mac => "aa-bb-cc-dd-ee-ff-00-11-22-33-44-55-66-77-88-99-aa-bb-cc-dd"
    assert_equal "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd", host.mac
  end

  test "should fix 64-bit mac address" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff00112233445566778899aabbccdd"
    assert_equal "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd", host.mac
  end

  test "should keep valid 64-bit mac address" do
    host = Host.create :name => "myhost", :mac => "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd"
    assert_equal "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd", host.mac
  end

  test "should be valid using 64-bit mac address" do
    host = hosts(:one)
    host.mac = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd"
    host.save!
    assert_equal true, host.valid?
  end

  test "should fix ip address if a leading zero is used" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff", :ip => "123.01.02.03"
    assert_equal "123.1.2.3", host.ip
  end

  test "should add domain name to hostname" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "myhost.company.com", host.name
  end

  test "should not add domain name to hostname if it already include it" do
    host = Host.create :name => "myhost.company.com", :mac => "aabbccddeeff", :ip => "123.1.2.3",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "myhost.company.com", host.name
  end

  test "should add hostname if it contains domain name" do
    host = Host.create :name => "myhost.company.com", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "myhost.company.com", host.name
  end

  test "should not append domainname to fqdn" do
    host = Host.create :name => "myhost.sub.comp.net", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com"),
      :certname => "myhost.sub.comp.net",
      :managed => false
    assert_equal "myhost.sub.comp.net", host.name
  end

  test "should save hosts with full stop in their name" do
    host = Host.create :name => "my.host.company.com", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "my.host.company.com", host.name
  end

  test "sets compute attributes on create" do
    Host.any_instance.expects(:set_compute_attributes).once.returns(true)
    Host.create! :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.3",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :medium => media(:one),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :puppet_proxy => smart_proxies(:puppetmaster),
      :environment => environments(:production), :disk => "empty partition"
  end

  test "doesn't set compute attributes on update" do
    host = hosts(:one)
    Host.any_instance.expects(:set_compute_attributes).never
    host.update_attributes!(:mac => "52:54:00:dd:ee:ff")
  end

  context "when unattended is false" do
    def setup
      SETTINGS[:unattended] = false
    end

    def teardown
      SETTINGS[:unattended] = true
    end

    test "should be able to save hosts with full domain" do
      host = Host.create :name => "myhost.foo", :mac => "aabbccddeeff", :ip => "123.01.02.03"
      assert_equal "myhost.foo", host.fqdn
    end

    test "should be able to save hosts with no domain" do
      host = Host.create :name => "myhost", :mac => "aabbccddeeff", :ip => "123.01.02.03"
      assert_equal "myhost", host.fqdn
    end
  end

  test "should be able to save host" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.3",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :medium => media(:one),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :puppet_proxy => smart_proxies(:puppetmaster),
      :environment => environments(:production), :disk => "empty partition"
    assert host.valid?
    assert !host.new_record?
  end

  test "non-admin user should be able to create host with new lookup value" do
    User.current = users(:one)
    User.current.roles << [roles(:manager)]
    assert_difference('LookupValue.count') do
      assert Host.create! :name => "abc.mydomain.net", :mac => "aabbecddeeff", :ip => "2.3.4.3",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :puppet_proxy => smart_proxies(:puppetmaster), :medium => media(:one),
      :environment => environments(:production), :disk => "empty partition",
      :lookup_values_attributes => {"new_123456" => {"lookup_key_id" => lookup_keys(:complex).id, "value"=>"some_value", "match" => "fqdn=abc.mydomain.net"}}
    end
  end

  test "lookup value has right matcher for a host" do
    assert_difference('LookupValue.where(:lookup_key_id => lookup_keys(:five).id, :match => "fqdn=abc.mydomain.net").count') do
      h = Host.create! :name => "abc", :mac => "aabbecddeeff", :ip => "2.3.4.3",
        :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :medium => media(:one),
        :subnet => subnets(:one), :architecture => architectures(:x86_64), :puppet_proxy => smart_proxies(:puppetmaster),
        :environment => environments(:production), :disk => "empty partition",
        :lookup_values_attributes => {"new_123456" => {"lookup_key_id" => lookup_keys(:five).id, "value"=>"some_value"}}
    end
  end

  test "should be able to add new lookup value on update_attributes" do
    host = hosts(:redhat) #temp01.yourdomain.net
    lookup_key = lookup_keys(:three)
    assert_difference('LookupValue.count') do
      assert host.update_attributes!(:lookup_values_attributes => {:new_123456 =>
        {:lookup_key_id => lookup_key.id, :value => true, :match => "fqdn=temp01.yourdomain.net",
          :_destroy => 'false'}})
    end
  end

  test "should be able to delete existing lookup value on update_attributes" do
    #in fixtures lookup_keys.yml, lookup_values(:one) has hosts(:one) and lookup_keys(:one)
    host = hosts(:one)
    lookup_key = lookup_keys(:one)
    lookup_value = lookup_values(:one)
    assert_difference('LookupValue.count', -1) do
      assert host.update_attributes!(:lookup_values_attributes => {'0' =>
        {:lookup_key_id => lookup_key.id, :value => '8080', :match => "fqdn=temp01.yourdomain.net",
          :id => lookup_values(:one).id, :_destroy => 'true'}})
    end
  end

  test "should be able to update lookup value on update_attributes" do
    #in fixtures lookup_keys.yml, lookup_values(:one) has hosts(:one) and lookup_keys(:one)
    host = hosts(:one)
    lookup_key = lookup_keys(:one)
    lookup_value = lookup_values(:one)
    assert_difference('LookupValue.count', 0) do
      assert host.update_attributes!(:lookup_values_attributes => {'0' =>
        {:lookup_key_id => lookup_key.id, :value => '80', :match => "fqdn=temp01.yourdomain.net",
          :id => lookup_values(:one).id, :_destroy => 'false'}})
    end
    lookup_value.reload
    assert_equal 80, lookup_value.value
  end

  test "should import facts from json stream" do
    h=Host.new(:name => "sinn1636.lan")
    h.disk = "!" # workaround for now
    assert h.import_facts(JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.json")))['facts'])
  end

  context 'import host and facts' do
    test 'should import facts from json of a new host when certname is not specified' do
      refute Host.find_by_name('sinn1636.lan')
      raw = parse_json_fixture('/facts.json')
      assert Host.import_host_and_facts(raw['name'], raw['facts'])
      assert Host.find_by_name('sinn1636.lan')
    end

    test 'should downcase hostname parameter from json of a new host' do
      raw = parse_json_fixture('/facts_with_caps.json')
      assert Host.import_host_and_facts(raw['name'], raw['facts'])
      assert Host.find_by_name('sinn1636.lan')
    end

    test 'should import facts idempotently' do
      raw = parse_json_fixture('/facts_with_caps.json')
      assert Host.import_host_and_facts(raw['name'], raw['facts'])
      value_ids = Host.find_by_name('sinn1636.lan').fact_values.map(&:id)
      assert Host.import_host_and_facts(raw['name'], raw['facts'])
      assert_equal value_ids.sort, Host.find_by_name('sinn1636.lan').fact_values.map(&:id).sort
    end

    test 'should find a host by certname not fqdn when provided' do
      Host.new(:name => 'sinn1636.fail', :certname => 'sinn1636.lan.cert').save(:validate => false)
      assert Host.find_by_name('sinn1636.fail').ip.nil?
      # hostname in the json is sinn1636.lan, so if the facts have been updated for
      # this host, it's a successful identification by certname
      raw = parse_json_fixture('/facts_with_certname.json')
      assert Host.import_host_and_facts(raw['name'], raw['facts'], raw['certname'])
      assert_equal '10.35.27.2', Host.find_by_name('sinn1636.fail').ip
    end

    test 'should update certname when host is found by hostname and certname is provided' do
      Host.new(:name => 'sinn1636.lan', :certname => 'sinn1636.cert.fail').save(:validate => false)
      assert_equal 'sinn1636.cert.fail', Host.find_by_name('sinn1636.lan').certname
      raw = parse_json_fixture('/facts_with_certname.json')
      assert Host.import_host_and_facts(raw['name'], raw['facts'], raw['certname'])
      assert_equal 'sinn1636.lan.cert', Host.find_by_name('sinn1636.lan').certname
    end

    test 'host is created when uploading facts if setting is true' do
      assert_difference 'Host.count' do
        Setting[:create_new_host_when_facts_are_uploaded] = true
        raw = parse_json_fixture('/facts_with_certname.json')
        Host.import_host_and_facts(raw['name'], raw['facts'], raw['certname'])
        assert Host.find_by_name('sinn1636.lan')
        Setting[:create_new_host_when_facts_are_uploaded] =
          Setting.find_by_name('create_new_host_when_facts_are_uploaded').default
      end
    end

    test 'host is not created when uploading facts if setting is false' do
      Setting[:create_new_host_when_facts_are_uploaded] = false
      assert_equal false, Setting[:create_new_host_when_facts_are_uploaded]
      raw = parse_json_fixture('/facts_with_certname.json')
      assert Host.import_host_and_facts(raw['name'], raw['facts'], raw['certname'])
      host = Host.find_by_name('sinn1636.lan')
      Setting[:create_new_host_when_facts_are_uploaded] =
        Setting.find_by_name('create_new_host_when_facts_are_uploaded').default
      assert_nil host
    end

    test 'host taxonomies are set to a default when uploading facts' do
      Setting[:create_new_host_when_facts_are_uploaded] = true
      raw = parse_json_fixture('/facts.json')
      Host.import_host_and_facts(raw['name'], raw['facts'])

      assert_equal Setting[:default_location],     Host.find_by_name('sinn1636.lan').location.title
      assert_equal Setting[:default_organization], Host.find_by_name('sinn1636.lan').organization.title
    end

    test 'host taxonomies are set to setting[taxonomy_fact] if it exists' do
      Setting[:create_new_host_when_facts_are_uploaded] = true
      Setting[:location_fact] = "foreman_location"
      Setting[:organization_fact] = "foreman_organization"

      raw = parse_json_fixture('/facts.json')
      raw['facts']['foreman_location']     = 'Location 2'
      raw['facts']['foreman_organization'] = 'Organization 2'
      Host.import_host_and_facts(raw['name'], raw['facts'])

      assert_equal 'Location 2',     Host.find_by_name('sinn1636.lan').location.title
      assert_equal 'Organization 2', Host.find_by_name('sinn1636.lan').organization.title
    end

    test 'default taxonomies are not assigned to hosts with taxonomies' do
      Setting[:default_location] = taxonomies(:location1).title
      raw = parse_json_fixture('/facts.json')
      Host.import_host_and_facts(raw['name'], raw['facts'])
      Host.find_by_name('sinn1636.lan').update_attribute(:location, taxonomies(:location2))
      Host.find_by_name('sinn1636.lan').import_facts(raw['facts'])

      assert_equal taxonomies(:location2), Host.find_by_name('sinn1636.lan').location
    end

    test 'taxonomies from facts override already existing taxonomies in hosts' do
      Setting[:create_new_host_when_facts_are_uploaded] = true
      Setting[:location_fact] = "foreman_location"
      Setting[:organization_fact] = "foreman_organization"

      raw = parse_json_fixture('/facts.json')
      raw['facts']['foreman_location'] = 'Location 2'
      Host.import_host_and_facts(raw['name'], raw['facts'])

      Host.find_by_name('sinn1636.lan').update_attribute(:location, taxonomies(:location1))
      Host.find_by_name('sinn1636.lan').import_facts(raw['facts'])

      assert_equal taxonomies(:location2), Host.find_by_name('sinn1636.lan').location
    end
  end

  test "host is created when receiving a report if setting is true" do
    assert_difference 'Host.count' do
      Setting[:create_new_host_when_report_is_uploaded] = true
      Report.import parse_json_fixture("/../fixtures/report-no-logs.json")
      assert Host.find_by_name('builder.fm.example.net')
      Setting[:create_new_host_when_report_is_uploaded] =
        Setting.find_by_name("create_new_host_when_facts_are_uploaded").default
    end
  end

  test "host is not created when receiving a report if setting is false" do
    Setting[:create_new_host_when_report_is_uploaded] = false
    assert_equal false, Setting[:create_new_host_when_report_is_uploaded]
    Report.import parse_json_fixture("/../fixtures/report-no-logs.json")
    host = Host.find_by_name('builder.fm.example.net')
    Setting[:create_new_host_when_report_is_uploaded] =
        Setting.find_by_name("create_new_host_when_facts_are_uploaded").default
    assert_nil host
  end

  test "assign a host to a location" do
    host = Host.create :name => "host 1", :mac => "aabbecddeeff", :ip => "5.5.5.5", :hostgroup => hostgroups(:common), :managed => false
    location = Location.create :name => "New York"

    host.location_id = location.id
    assert host.save!
  end

  test "update a host's location" do
    host = Host.create :name => "host 1", :mac => "aabbccddee", :ip => "5.5.5.5", :hostgroup => hostgroups(:common), :managed => false
    original_location = Location.create :name => "New York"

    host.location_id = original_location.id
    assert host.save!
    assert host.location_id = original_location.id

    new_location = Location.create :name => "Los Angeles"
    host.location_id = new_location.id
    assert host.save!
    assert host.location_id = new_location.id
  end

  test "assign a host to an organization" do
    host = Host.create :name => "host 1", :mac => "aabbecddeeff", :ip => "5.5.5.5", :hostgroup => hostgroups(:common), :managed => false
    organization = Organization.create :name => "Hosting client 1"

    host.organization_id = organization.id
    assert host.save!
  end

  test "assign a host to both a location and an organization" do
    host = Host.create :name => "host 1", :mac => "aabbccddeeff", :ip => "5.5.5.5", :hostgroup => hostgroups(:common), :managed => false
    location = Location.create :name => "Tel Aviv"
    organization = Organization.create :name => "Hosting client 1"

    host.location_id = location.id
    host.organization_id = organization.id

    assert host.save!
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

  test "should not save if root password is undefined when the host is managed" do
    host = Host.new :name => "myfullhost", :managed => true
    assert !host.valid?
    assert host.errors[:root_pass].any?
  end

  test "should save if root password is undefined when the compute resource is image capable" do
    host = Host.new :name => "myfullhost", :managed => true, :compute_resource_id => compute_resources(:openstack).id
    host.valid?
    refute host.errors[:root_pass].any?
  end

  test "should not save if neither ptable or disk are defined when the host is managed" do
    if unattended?
      host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.4.4.03",
        :domain => domains(:mydomain), :operatingsystem => Operatingsystem.first, :subnet => subnets(:one), :medium => media(:one),
        :architecture => Architecture.first, :environment => Environment.first, :managed => true
      assert !host.valid?
    end
  end

  test "should save if neither ptable or disk are defined when the host is not managed" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03", :medium => media(:one),
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => false
    assert host.valid?
  end

  test "should save if ptable is defined" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :puppet_proxy => smart_proxies(:puppetmaster), :medium => media(:one),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :ptable => Ptable.first
    assert !host.new_record?
  end

  test "should save if disk is defined" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :medium => media(:one),
      :architecture => architectures(:x86_64), :environment => environments(:production), :disk => "aaa", :puppet_proxy => smart_proxies(:puppetmaster)
    assert !host.new_record?
  end

  test "should not save if IP is not in the right subnet" do
    if unattended?
      host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03", :ptable => ptables(:one),
        :domain => domains(:mydomain), :operatingsystem => Operatingsystem.first, :subnet => subnets(:one), :managed => true, :medium => media(:one),
        :architecture => Architecture.first, :environment => Environment.first, :ptable => Ptable.first, :puppet_proxy => smart_proxies(:puppetmaster)
      assert !host.valid?
    end
  end

  test "should save if owner_type is User or Usergroup" do
    host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03", :ptable => ptables(:one), :medium => media(:one),
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => true,
      :owner_type => "User", :root_pass => "xybxa6JUkz63w"
    assert host.valid?
  end

  test "should not save if owner_type is not User or Usergroup" do
    host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03", :medium => media(:one),
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => true,
      :owner_type => "UserGr(up" # should be Usergroup
    assert !host.valid?
  end

  test "should not save if installation media is missing" do
    host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03", :ptable => ptables(:one),
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => true, :build => true,
      :owner_type => "User", :root_pass => "xybxa6JUkz63w"
    refute host.valid?
    assert_equal "can't be blank", host.errors[:medium_id][0]
  end

  test "should save if owner_type is empty and Host is unmanaged" do
    host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03", :medium => media(:one),
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => false
    assert host.valid?
  end

  test "should import from external nodes output" do
    # create a dummy node
    Parameter.destroy_all
    host = Host.create :name => "myfullhost", :mac => "aabbacddeeff", :ip => "2.3.4.12", :medium => media(:one),
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one),
      :architecture => architectures(:x86_64), :environment => environments(:production), :disk => "aaa",
      :puppet_proxy => smart_proxies(:puppetmaster)

    # dummy external node info
    nodeinfo = {"environment" => "production",
      "parameters"=> {"puppetmaster"=>"puppet", "MYVAR"=>"value", "port" => "80",
        "ssl_port" => "443", "foreman_env"=> "production", "owner_name"=>"Admin User",
        "root_pw"=>"xybxa6JUkz63w", "owner_email"=>"admin@someware.com"},
      "classes"=>{"apache"=>{"custom_class_param"=>"abcdef"}, "base"=>{"cluster"=>"secret"}} }

    host.importNode nodeinfo
    nodeinfo["parameters"]["special_info"] = "secret"  # smart variable on apache

    assert_equal nodeinfo, host.info
  end

  test "show be enabled by default" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff"
    assert host.enabled?
  end

  test "host can be disabled" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff"
    host.enabled = false
    host.save
    assert host.disabled?
  end

  test "a fqdn Host should be assigned to a domain if such domain exists" do
    domain = domains(:mydomain)
    host = Host.create :name => "host.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :medium => media(:one),
      :architecture => architectures(:x86_64), :environment => environments(:production), :disk => "aaa"
    host.valid?
    assert_equal domain, host.domain
  end

  context 'associated config templates' do
    setup do
      @host = Host.create(:name => "host.mydomain.net", :mac => "aabbccddeaff",
                          :ip => "2.3.04.03",           :medium => media(:one),
                          :operatingsystem => Operatingsystem.find_by_name("Redhat"),
                          :subnet => subnets(:one), :hostgroup => Hostgroup.find_by_name("common"),
                          :architecture => Architecture.first, :disk => "aaa",
                          :environment => Environment.find_by_name("production"))
    end

    test "retrieves iPXE template if associated to the correct env and host group" do
      assert_equal ConfigTemplate.find_by_name("MyString"), @host.configTemplate({:kind => "iPXE"})
    end

    test "retrieves provision template if associated to the correct host group only" do
      assert_equal ConfigTemplate.find_by_name("MyString2"), @host.configTemplate({:kind => "provision"})
    end

    test "retrieves script template if associated to the correct OS only" do
      assert_equal ConfigTemplate.find_by_name("MyScript"), @host.configTemplate({:kind => "script"})
    end

    test "retrieves finish template if associated to the correct environment only" do
      assert_equal ConfigTemplate.find_by_name("MyFinish"), @host.configTemplate({:kind => "finish"})
    end
  end

  test "handle_ca must not perform actions when the manage_puppetca setting is false" do
    h = hosts(:one)
    Setting[:manage_puppetca] = false
    h.expects(:initialize_puppetca).never()
    h.expects(:setAutosign).never()
    assert h.handle_ca
  end

  test "handle_ca must not perform actions when no Puppet CA proxy is associated" do
    h = hosts(:one)
    Setting[:manage_puppetca] = true
    refute h.puppetca?
    h.expects(:initialize_puppetca).never()
    assert h.handle_ca
  end

  test "handle_ca must call initialize, delete cert and add autosign methods" do
    h = hosts(:dhcp)
    Setting[:manage_puppetca] = true
    assert h.puppetca?
    h.expects(:initialize_puppetca).returns(true)
    h.expects(:delCertificate).returns(true)
    h.expects(:setAutosign).returns(true)
    assert h.handle_ca
  end

  test "if the user toggles off the use_uuid_for_certificates option, revoke the UUID and autosign the hostname" do
    h = hosts(:dhcp)
    Setting[:manage_puppetca] = true
    assert h.puppetca?

    Setting[:use_uuid_for_certificates] = false
    some_uuid = Foreman.uuid
    h.certname = some_uuid

    h.expects(:initialize_puppetca).returns(true)
    mock_puppetca = Object.new
    mock_puppetca.expects(:del_certificate).with(some_uuid).returns(true)
    mock_puppetca.expects(:set_autosign).with(h.name).returns(true)
    h.instance_variable_set("@puppetca", mock_puppetca)

    assert h.handle_ca
    assert_equal h.certname, h.name
  end

  test "if the user changes a hostname in non-use_uuid_for_cetificates mode, revoke the old hostname and autosign the new hostname" do
    Setting[:use_uuid_for_certificates] = false
    Setting[:manage_puppetca] = true

    h = hosts(:dhcp)
    assert h.puppetca?

    old_name = 'oldhostname'
    h.certname = old_name

    h.expects(:initialize_puppetca).returns(true)
    mock_puppetca = Object.new
    mock_puppetca.expects(:del_certificate).with(old_name).returns(true)
    mock_puppetca.expects(:set_autosign).with(h.name).returns(true)
    h.instance_variable_set("@puppetca", mock_puppetca)

    assert h.handle_ca
    assert_equal h.certname, h.name
  end

  test "custom_disk_partition_with_erb" do
    h = hosts(:one)
    h.disk = "<%= 1 + 1 %>"
    assert h.save
    assert h.disk.present?
    assert_equal "2", h.diskLayout
  end

  test "models are updated when host.model has no value" do
    h = hosts(:one)
    f = fact_names(:kernelversion)
    as_admin do
      fact_value = FactValue.where(:fact_name_id => f.id).first
      fact_value.update_attributes!(:value => "superbox")
    end
    assert_difference('Model.count') do
      facts = JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.json")))
      h.populate_fields_from_facts facts['facts']
    end
  end

  test "hostgroup should set default values when none exists" do
    # should set os, but not arch
    hg = hostgroups(:common)
    h  = Host.new
    h.hostgroup = hg
    h.architecture = architectures(:sparc)
    assert !h.valid?
    assert_equal hg.operatingsystem, h.operatingsystem
    assert_not_equal hg.architecture , h.architecture
    assert_equal h.architecture, architectures(:sparc)
  end

  test "host os attributes must be associated with the host os" do
    h = hosts(:one)
    h.managed = true
    h.architecture = architectures(:sparc)
    assert !h.os.architectures.include?(h.arch)
    assert !h.valid?
    assert_equal ["#{h.architecture} does not belong to #{h.os} operating system"], h.errors[:architecture_id]
  end

  test "host puppet classes must belong to the host environment" do
    h = hosts(:one)

    pc = puppetclasses(:three)
    h.puppetclasses << pc
    assert !h.environment.puppetclasses.map(&:id).include?(pc.id)
    assert !h.valid?
    assert_equal ["#{pc} does not belong to the #{h.environment} environment"], h.errors[:puppetclasses]
  end

  test "when changing host environment, its puppet classes should be verified" do
    h = hosts(:two)
    pc = puppetclasses(:one)
    h.puppetclasses << pc
    assert h.save
    h.environment = environments(:testing)
    assert !h.save
    assert_equal ["#{pc} does not belong to the #{h.environment} environment"], h.errors[:puppetclasses]
  end

  test "should not allow short root passwords for managed host" do
    h = hosts(:one)
    h.root_pass = "2short"
    h.valid?
    assert h.errors[:root_pass].include?("should be 8 characters or more")
  end

  test "should allow to save root pw" do
    h = hosts(:one)
    pw = h.root_pass
    h.root_pass = "12345678"
    h.hostgroup = nil
    assert h.save!
    assert_not_equal pw, h.root_pass
  end

  test "should allow to revert to default root pw" do
    Setting[:root_pass] = "$1$default$hCkak1kaJPQILNmYbUXhD0"
    h = hosts(:one)
    h.root_pass = "xybxa6JUkz63w"
    assert h.save
    h.root_pass = nil
    assert h.save!
    assert_equal h.root_pass, Setting.root_pass
  end

  test "should generate a random salt when saving root pw" do
    h = hosts(:one)
    pw = h.root_pass
    h.hostgroup = nil
    h.root_pass = "xybxa6JUkz63w"
    assert h.save!
    first = h.root_pass

    # Check it's a $.$....$...... enhanced style password
    assert_equal 4, first.split('$').count
    assert first.split('$')[2].size >= 8

    # Check it changes
    h.root_pass = "12345678"
    assert h.save
    assert_not_equal first.split('$')[2], h.root_pass.split('$')[2]
  end

  test "should pass through existing salt when saving root pw" do
    h = hosts(:one)
    pass = "$1$jmUiJ3NW$bT6CdeWZ3a6gIOio5qW0f1"
    h.root_pass = pass
    h.hostgroup = nil
    assert h.save
    assert_equal pass, h.root_pass
  end

  test "should use hostgroup root password" do
    h = hosts(:one)
    h.root_pass = nil
    h.hostgroup = hostgroups(:common)
    assert h.save
    h.hostgroup.update_attribute(:root_pass, "abc")
    assert h.root_pass.present? && h.root_pass != Setting[:root_pass]
  end

  test "should use a nested hostgroup parent root password" do
    h = hosts(:one)
    h.root_pass = nil
    h.hostgroup = hg = hostgroups(:common)
    assert h.save
    hg.parent = hostgroups(:unusual)
    hg.root_pass = nil
    hg.parent.update_attribute(:root_pass, "abc")
    hg.save
    assert h.root_pass.present? && h.root_pass != Setting[:root_pass]
  end

  test "should use settings root password" do
    Setting[:root_pass] = "$1$default$hCkak1kaJPQILNmYbUXhD0"
    h = hosts(:one)
    h.root_pass = nil
    h.hostgroup = nil
    assert h.save
    assert h.root_pass.present? && h.root_pass == Setting[:root_pass]
  end

  test "should save uuid on managed hosts" do
    Setting[:use_uuid_for_certificates] = true
    host = Host.create :name => "myhost1", :mac => "aabbecddeeff", :ip => "2.3.4.3", :hostgroup => hostgroups(:common), :managed => true
    assert host.valid?
    assert !host.new_record?
    assert_not_nil host.certname
    assert_not_equal host.name, host.certname
  end

  test "should not save uuid on non managed hosts" do
    Setting[:use_uuid_for_certificates] = true
    host = Host.create :name => "myhost1", :mac => "aabbecddeeff", :ip => "2.3.4.3", :hostgroup => hostgroups(:common), :managed => false
    assert host.valid?
    assert !host.new_record?
    assert_equal host.name, host.certname
  end

  test "should not save uuid when settings disable it" do
    Setting[:use_uuid_for_certificates] = false
    host = Host.create :name => "myhost1", :mac => "aabbecddeeff", :ip => "2.3.4.3", :hostgroup => hostgroups(:common), :managed => false
    assert host.valid?
    assert !host.new_record?
    assert_equal host.name, host.certname
  end

  test "all whitespace should be removed from hostname" do
    host = Host.create :name => "my host 1	", :mac => "aabbecddeeff", :ip => "2.3.4.3", :hostgroup => hostgroups(:common), :managed => false
    assert host.valid?
    assert !host.new_record?
    assert_equal "myhost1.mydomain.net", host.name
  end

  test "should have only one bootable interface" do
    h = hosts(:redhat)
    assert_equal 0, h.interfaces.count
    bootable = Nic::Bootable.create! :host => h, :name => "dummy-bootable", :ip => "2.3.4.102", :mac => "aa:bb:cd:cd:ee:ff",
                                     :subnet => h.subnet, :type => 'Nic::Bootable', :domain => h.domain, :managed => false
    assert_equal 1, h.interfaces.count
    h.interfaces_attributes = [{:name => "dummy-bootable2", :ip => "2.3.4.103", :mac => "aa:bb:cd:cd:ee:ff",
                                :subnet_id => h.subnet_id, :type => 'Nic::Bootable', :domain_id => h.domain_id,
                                :managed => false }]
    assert !h.valid?
    assert_equal "Only one bootable interface is allowed", h.errors['interfaces.type'][0]
    assert_equal 1, h.interfaces.count
  end

  test "#set_interfaces skips primary physical interface but updates primary_interface attribute of host" do
    host, parser = setup_host_with_nic_parser({:macaddress => '00:00:00:11:22:33', :virtual => false, :ipaddress => '10.0.0.200'})
    host.update_attribute :mac, '00:00:00:11:22:33'
    host.update_attribute :ip, '10.0.0.100'
    assert_nil host.primary_interface

    # physical NICs with same MAC are skipped
    assert_no_difference 'Nic::Base.count' do
      host.set_interfaces(parser)
    end
    assert_equal '10.0.0.100', host.ip
    assert_equal 'eth0', host.primary_interface
  end


  test "#set_interfaces updates existing physical interface" do
    host, parser = setup_host_with_nic_parser({:macaddress => '00:00:00:11:22:33', :virtual => false, :ipaddress => '10.0.0.200', :link => false})
    FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:11:22:33', :ip => '10.10.0.1', :link => true)

    assert_no_difference 'Nic::Base.count' do
      host.set_interfaces(parser)
    end
    assert_equal '10.0.0.200', host.interfaces.where(:mac => '00:00:00:11:22:33').first.ip
    refute host.interfaces.where(:mac => '00:00:00:11:22:33').first.link
  end

  test "#set_interfaces creates new physical interface" do
    host, parser = setup_host_with_nic_parser({:macaddress => '00:00:00:11:22:33', :virtual => false, :ipaddress => '10.10.0.1'})

    # physical NICs with same MAC are created
    assert_difference 'host.interfaces(true).count' do
      host.set_interfaces(parser)
    end
    assert_equal '10.10.0.1', host.interfaces.where(:mac => '00:00:00:11:22:33').first.ip
  end

  test "#set_interfaces creates new interface with link up if no link fact specified" do
    host, parser = setup_host_with_nic_parser({:macaddress => '00:00:00:11:22:33', :virtual => false, :ipaddress => '10.10.0.1'})
    host.set_interfaces(parser)
    assert host.interfaces.where(:mac => '00:00:00:11:22:33').first.link
  end

  test "#set_interfaces creates new interface even if primary interface has same MAC" do
    host, parser = setup_host_with_nic_parser({:macaddress => '00:00:00:11:22:33', :virtual => true, :ipaddress => '10.10.0.1', :physical_device => 'eth0', :identifier => 'eth0_0'})
    host.update_attribute :mac, '00:00:00:11:22:33'
    host.update_attribute :ip, '10.0.0.100'

    assert_difference 'host.interfaces(true).count' do
      host.set_interfaces(parser)
    end
    assert_equal '10.0.0.100', host.ip
  end

  test "#set_interfaces creates new interface even if another virtual interface has same MAC but another identifier" do
    host, parser = setup_host_with_nic_parser({:macaddress => '00:00:00:11:22:33', :virtual => true, :ipaddress => '10.10.0.2', :identifier => 'eth0_1', :physical_device => 'eth0'})
    FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:11:22:33', :ip => '10.10.0.1', :virtual => true, :identifier => 'eth0_0', :physical_device => 'eth0')

    assert_difference 'host.interfaces(true).count' do
      host.set_interfaces(parser)
    end
  end

  test "#set_interfaces updates existing virtual interface only if it has same MAC and identifier" do
    host, parser = setup_host_with_nic_parser({:macaddress => '00:00:00:11:22:33', :virtual => true, :ipaddress => '10.10.0.1', :physical_device => 'eth0', :identifier => 'eth0_0'})
    FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:11:22:33', :ip => '10.10.0.200', :virtual => true, :physical_device => 'eth0', :identifier => 'eth0_0')

    assert_no_difference 'host.interfaces(true).count' do
      host.set_interfaces(parser)
    end
    assert_equal '10.10.0.1', host.interfaces.first.ip
  end

  test "#set_interfaces creates IPMI device if parameters are found" do
    host, parser = setup_host_with_ipmi_parser({:ipaddress => '192.168.0.1', :macaddress => '00:00:00:11:33:55'})

    assert_difference 'host.interfaces(true).count' do
      host.set_interfaces(parser)
    end
    bmc = host.interfaces.where(:type => 'Nic::BMC').first
    assert_equal '192.168.0.1', bmc.ip
    assert_equal '00:00:00:11:33:55', bmc.mac
  end

  test "#set_interfaces updates IPMI device if parameters are found and there's existing IPMI with same MAC" do
    host, parser = setup_host_with_ipmi_parser({:ipaddress => '192.168.0.1', :macaddress => '00:00:00:11:33:55'})
    FactoryGirl.create(:nic_bmc, :host => host, :mac => '00:00:00:11:33:55', :ip => '10.10.0.200', :virtual => false)

    assert_no_difference 'host.interfaces(true).count' do
      host.set_interfaces(parser)
    end
    bmcs = host.interfaces.where(:type => 'Nic::BMC')
    assert_equal 1, bmcs.count
    assert_equal '192.168.0.1', bmcs.first.ip
  end

  test "#set_interfaces updates associated virtuals identifier on identifier change" do
    # eth4 was renamed to eth5 (same MAC)
    host, parser = setup_host_with_nic_parser({:macaddress => '00:00:00:11:22:33', :ipaddress => '10.10.0.1', :virtual => false, :identifier => 'eth5'})
    physical = FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:11:22:33', :ip => '10.10.0.1', :identifier => 'eth4')
    virtual = FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:11:22:33', :virtual => true, :ip => '10.10.0.2', :identifier => 'eth4.1', :physical_device => 'eth4')

    host.set_interfaces(parser)
    virtual.reload
    assert_equal 'eth5.1', virtual.identifier
    assert_equal 'eth5', virtual.physical_device
  end

  test "set_interfaces updates associated virtuals identifier even on primary interface" do
    host, parser = setup_host_with_nic_parser({:macaddress => '00:00:00:11:22:33', :ipaddress => '10.10.0.1', :virtual => false, :identifier => 'eth1'})
    host.update_attribute :primary_interface, 'eth0'
    host.update_attribute :mac, '00:00:00:11:22:33'
    virtual = FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:11:22:33', :virtual => true, :ip => '10.10.0.2', :identifier => 'eth0.1', :physical_device => 'eth0')

    host.set_interfaces(parser)
    virtual.reload
    assert_equal 'eth1.1', virtual.identifier
    assert_equal 'eth1', virtual.physical_device
  end

  test "#set_interfaces updates associated virtuals identifier on identifier change mutualy exclusively" do
    # eth4 was renamed to eth5 and eth5 renamed to eth4
    host = FactoryGirl.create(:host, :hostgroup => FactoryGirl.create(:hostgroup))
    hash = { :eth5 => {:macaddress => '00:00:00:11:22:33', :ipaddress => '10.10.0.1', :virtual => false},
             :eth4 => {:macaddress => '00:00:00:44:55:66', :ipaddress => '10.10.0.2', :virtual => false},
           }.with_indifferent_access
    parser = stub(:interfaces => hash, :ipmi_interface => {})
    physical4 = FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:11:22:33', :ip => '10.10.0.1', :identifier => 'eth4')
    physical5 = FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:44:55:66', :ip => '10.10.0.2', :identifier => 'eth5')
    virtual4 = FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:11:22:33', :virtual => true, :ip => '10.10.0.10', :identifier => 'eth4.1', :physical_device => 'eth4')
    virtual5 = FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:44:55:66', :virtual => true, :ip => '10.10.0.20', :identifier => 'eth5.1', :physical_device => 'eth5')

    host.set_interfaces(parser)
    physical4.reload
    physical5.reload
    virtual4.reload
    virtual5.reload
    assert_equal 'eth5', physical4.identifier
    assert_equal 'eth4', physical5.identifier
    assert_equal 'eth5.1', virtual4.identifier
    assert_equal 'eth4.1', virtual5.identifier
    assert_equal 'eth5', virtual4.physical_device
    assert_equal 'eth4', virtual5.physical_device
  end

  test "#set_interfaces does not allow two physical devices with same IP, it ignores the second" do
    host = FactoryGirl.create(:host, :hostgroup => FactoryGirl.create(:hostgroup))
    hash = { :eth1 => {:macaddress => '00:00:00:11:22:33', :ipaddress => '10.10.0.1', :virtual => false},
             :eth2 => {:macaddress => '00:00:00:44:55:66', :ipaddress => '10.10.0.2', :virtual => false},
           }.with_indifferent_access
    parser = stub(:interfaces => hash, :ipmi_interface => {})
    FactoryGirl.create(:nic_managed, :host => host, :mac => '00:00:00:77:88:99', :ip => '10.10.0.1', :virtual => false, :identifier => 'eth0')

    host.set_interfaces(parser)
    host.reload
    assert_includes host.interfaces.map(&:identifier), 'eth0'
    assert_includes host.interfaces.map(&:identifier), 'eth2'
    refute_includes host.interfaces.map(&:identifier), 'eth1'
    assert_equal 2, host.interfaces.size
  end

  # Token tests

  test "built should clean tokens" do
    Setting[:token_duration] = 30
    h = hosts(:one)
    h.create_token(:value => "aaaaaa", :expires => Time.now)
    assert_equal Token.all.size, 1
    h.expire_token
    assert_equal Token.all.size, 0
  end

  test "built should clean tokens even when tokens are disabled" do
    Setting[:token_duration] = 0
    h = hosts(:one)
    h.create_token(:value => "aaaaaa", :expires => Time.now)
    assert_equal Token.all.size, 1
    h.expire_token
    assert_equal Token.all.size, 0
  end

  test "hosts should be able to retrieve their token if one exists" do
    Setting[:token_duration] = 30
    h = hosts(:one)
    assert_equal Token.first, h.token
  end

  test "token should return false when tokens are disabled or invalid" do
    Setting[:token_duration] = 0
    h = hosts(:one)
    assert_equal h.token, nil
    Setting[:token_duration] = 30
    h = hosts(:one)
    assert_equal h.token, nil
  end

  test "a token can be matched to a host" do
    h = hosts(:one)
    h.create_token(:value => "aaaaaa", :expires => Time.now + 1.minutes)
    assert_equal h, Host.for_token("aaaaaa").first
  end

  test "a token cannot be matched to a host when expired" do
    h = hosts(:one)
    h.create_token(:value => "aaaaaa", :expires => 1.minutes.ago)
    refute Host.for_token("aaaaaa").first
  end

  test "deleting an host with an expired token does not cause a Foreign Key error" do
    h=hosts(:one)
    h.create_token(:value => "aaaaaa", :expires => 5.minutes.ago)
    assert_nothing_raised(ActiveRecord::InvalidForeignKey) {h.reload.destroy}
  end

  test "can search hosts by hostgroup" do
    #setup - add parent to hostgroup :common (not in fixtures, since no field parent_id)
    hostgroup = hostgroups(:db)
    parent_hostgroup = hostgroups(:common)
    hostgroup.parent_id = parent_hostgroup.id
    assert hostgroup.save!

    # search hosts by hostgroup label
    hosts = Host.search_for("hostgroup_title = #{hostgroup.title}")
    assert_equal 1, hosts.count  #host_db in hosts.yml
    assert_equal hosts.first.hostgroup_id, hostgroup.id
  end

  test "can search hosts by parent hostgroup and its descendants" do
    #setup - add parent to hostgroup :common (not in fixtures, since no field parent_id)
    hostgroup = hostgroups(:db)
    parent_hostgroup = hostgroups(:common)
    hostgroup.parent_id = parent_hostgroup.id
    assert hostgroup.save!

    # search hosts by parent hostgroup label
    hosts = Host::Managed.search_for("parent_hostgroup = Common")
    assert_equal hosts.count, 2
    assert_equal ["Common", "Common/db"].sort, hosts.map { |h| h.hostgroup.title }.sort
  end

  test "non-admin user with edit_hosts permission can update interface" do
    @one = users(:one)
    # add permission for user :one
    as_admin do
      filter = FactoryGirl.build(:filter)
      filter.permissions = [ Permission.find_by_name('edit_hosts') ]
      filter.save!
      role = Role.find_or_create_by_name :name => "testing_role"
      role.filters = [ filter ]
      role.save!
      @one.roles = [ role ]
      @one.save!
    end
    h = hosts(:one)
    assert h.interfaces.create :mac => "cabbccddeeff", :host => hosts(:one), :type => 'Nic::BMC',
                               :provider => "IPMI", :username => "root", :password => "secret", :ip => "10.35.19.35"
    as_user :one do
      assert h.update_attributes!("interfaces_attributes" => {"0" => {"mac"=>"59:52:10:1e:45:16"}})
    end
  end

  test "can auto-complete searches by host name" do
    as_admin do
      completions = Host::Managed.complete_for("name =")
      Host::Managed.all.each do |h|
        assert completions.include?("name = #{h.name}"), "completion missing: #{h}"
      end
    end
  end

  test "can auto-complete searches by facts" do
    as_admin do
      completions = Host::Managed.complete_for("facts.")
      FactName.order(:name).each do |fact|
        assert completions.include?(" facts.#{fact.name} "), "completion missing: #{fact}"
      end
    end
  end

  test "can auto-complete user searches by current_user" do
    as_admin do
      completions = Host::Managed.complete_for("user.login =")
      assert completions.include?("user.login = current_user"), "completion missing: current_user"
    end
  end

  test "can auto-complete owner searches by current_user" do
    as_admin do
      completions = Host::Managed.complete_for("owner = ")
      assert completions.include?("owner = current_user"), "completion missing: current_user"
    end
  end

  test "should accept lookup_values_attributes" do
    h = hosts(:redhat)
    as_admin do
      assert_difference "LookupValue.count" do
        assert h.update_attributes(:lookup_values_attributes => {"0" => {:lookup_key_id => lookup_keys(:one).id, :value => "8080" }})
      end
    end
  end

  test "can search hosts by params" do
    host = FactoryGirl.create(:host, :with_parameter)
    parameter = host.parameters.first
    results = Host.search_for(%Q{params.#{parameter.name} = "#{parameter.value}"})
    assert_equal 1, results.count
    assert_equal parameter.value, results.first.params[parameter.name]
  end

  test "can search hosts by current_user" do
    host = FactoryGirl.create(:host)
    results = Host.search_for("owner = current_user")
    assert_equal 1, results.count
    assert_equal results[0].owner, User.current
  end

  test "can search hosts by owner" do
    host = FactoryGirl.create(:host)
    results = Host.search_for("owner = " + User.current.login)
    assert_equal User.current.hosts.count, results.count
    assert_equal results[0].owner, User.current
  end

  test "can search hosts by inherited params from a hostgroup" do
    hg = hostgroups(:common)
    host = FactoryGirl.create(:host, :hostgroup => hg)
    parameter = hg.group_parameters.first
    results = Host.search_for(%Q{params.#{parameter.name} = "#{parameter.value}"})
    assert results.include?(host)
    assert_equal parameter.value, results.find(host).params[parameter.name]
  end

  test "can search hosts by inherited params from a parent hostgroup" do
    parent_hg = hostgroups(:common)
    hg = FactoryGirl.create(:hostgroup, :parent => parent_hg)
    host = FactoryGirl.create(:host, :hostgroup => hg)
    parameter = parent_hg.group_parameters.first
    results = Host.search_for(%Q{params.#{parameter.name} = "#{parameter.value}"})
    assert results.include?(host)
    assert_equal parameter.value, results.find(host).params[parameter.name]
  end

  test "can search hosts by puppet class" do
    host = FactoryGirl.create(:host, :with_puppetclass)
    results = Host.search_for("class = #{host.puppetclasses.first.name}")
    assert_equal 1, results.count
    assert_equal host.puppetclasses.first, results.first.puppetclasses.first
  end

  test "can search hosts by inherited puppet class from a hostgroup" do
    hg = FactoryGirl.create(:hostgroup, :with_puppetclass)
    host = FactoryGirl.create(:host, :hostgroup => hg, :environment => hg.environment)
    results = Host.search_for("class = #{hg.puppetclasses.first.name}")
    assert_equal 1, results.count
    assert_equal 0, results.first.puppetclasses.count
    assert_equal hg.puppetclasses.first, results.first.hostgroup.puppetclasses.first
  end

  test "can search hosts by inherited puppet class from a parent hostgroup" do
    parent_hg = FactoryGirl.create(:hostgroup, :with_puppetclass)
    hg = FactoryGirl.create(:hostgroup, :parent => parent_hg)
    host = FactoryGirl.create(:host, :hostgroup => hg, :environment => hg.environment)
    results = Host.search_for("class = #{parent_hg.puppetclasses.first.name}")
    assert_equal 1, results.count
    assert_equal 0, results.first.puppetclasses.count
    assert_equal 0, results.first.hostgroup.puppetclasses.count
    assert_equal parent_hg.puppetclasses.first, results.first.hostgroup.parent.puppetclasses.first
  end

  test "can search hosts by puppet class from config group in parent hostgroup" do
    hostgroup = FactoryGirl.create(:hostgroup, :with_config_group)
    host = FactoryGirl.create(:host, :hostgroup => hostgroup, :environment => hostgroup.environment)
    puppetclass = hostgroup.config_groups.first.puppetclasses.first
    results = Host.search_for("class = #{puppetclass.name}")
    assert_equal 1, results.count
    assert_equal host, results.first
  end

  test "should update puppet_proxy_id to the id of the validated proxy" do
    sp = smart_proxies(:puppetmaster)
    raw = parse_json_fixture('/facts_with_caps.json')
    Host.import_host_and_facts(raw['name'], raw['facts'], nil, sp.id)
    assert_equal sp.id, Host.find_by_name('sinn1636.lan').puppet_proxy_id
  end

  test "shouldn't update puppet_proxy_id if it has been set" do
    Host.new(:name => 'sinn1636.lan', :puppet_proxy_id => smart_proxies(:puppetmaster).id).save(:validate => false)
    sp = smart_proxies(:puppetmaster)
    raw = parse_json_fixture('/facts_with_certname.json')
    assert Host.import_host_and_facts(raw['name'], raw['facts'], nil, sp.id)
    assert_equal smart_proxies(:puppetmaster).id, Host.find_by_name('sinn1636.lan').puppet_proxy_id
  end

  # Ip validations
  test "unmanaged hosts don't require an IP" do
    h=Host.new
    refute h.require_ip_validation?
  end

  test "CRs without IP attribute don't require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the CR
    h=Host.new :managed => true,
      :compute_resource => compute_resources(:one),
      :compute_attributes => {:fake => "data"}
    refute h.require_ip_validation?
  end

  test "CRs with IP attribute and a DNS-enabled domain do not require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the CR
    h=Host.new :managed => true,
      :compute_resource => compute_resources(:openstack),
      :compute_attributes => {:fake => "data"},
      :domain => domains(:mydomain)
    refute h.require_ip_validation?
  end

  test "hosts with a DNS-enabled Domain do require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the domain
    h=Host.new :managed => true, :domain => domains(:mydomain)
    assert h.require_ip_validation?
  end

  test "hosts without a DNS-enabled Domain don't require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the domain
    h=Host.new :managed => true, :domain => domains(:useless)
    refute h.require_ip_validation?
  end

  test "hosts with a DNS-enabled Subnet do require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the subnet
    h=Host.new :managed => true, :subnet => subnets(:one)
    assert h.require_ip_validation?
  end

  test "hosts without a DNS-enabled Subnet don't require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the subnet
    h=Host.new :managed => true, :subnet => subnets(:four)
    refute h.require_ip_validation?
  end

  test "hosts with a DHCP-enabled Subnet do require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the subnet
    h=Host.new :managed => true, :subnet => subnets(:two)
    assert h.require_ip_validation?
  end

  test "hosts without a DHCP-enabled Subnet don't require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the subnet
    h=Host.new :managed => true, :subnet => subnets(:four)
    refute h.require_ip_validation?
  end

  test "with tokens enabled hosts don't require an IP" do
    Setting[:token_duration] = 30
    h=Host.new :managed => true
    refute h.require_ip_validation?
  end

  test "with tokens disabled PXE build hosts do require an IP" do
    h=Host.new :managed => true
    h.expects(:pxe_build?).returns(true)
    h.stubs(:image_build?).returns(false)
    assert h.require_ip_validation?
  end

  test "tokens disabled doesn't require an IP for image hosts" do
    h=Host.new :managed => true
    h.expects(:pxe_build?).returns(false)
    h.expects(:image_build?).returns(true)
    image = stub()
    image.expects(:user_data?).returns(false)
    h.stubs(:image).returns(image)
    refute h.require_ip_validation?
  end

  test "tokens disabled requires an IP for image hosts with user data" do
    h=Host.new :managed => true
    h.expects(:pxe_build?).returns(false)
    h.expects(:image_build?).returns(true)
    image = stub()
    image.expects(:user_data?).returns(true)
    h.stubs(:image).returns(image)
    assert h.require_ip_validation?
  end

  test "compute attributes are populated by hardware profile from hostgroup" do
    # hostgroups(:common) fixture has compute_profiles(:one)
    host = Host.new :name => "myhost", :hostgroup_id => hostgroups(:common).id, :compute_resource_id => compute_resources(:ec2).id, :managed => true
    host.expects(:queue_compute_create)
    assert host.valid?, host.errors.full_messages.to_sentence
    assert_equal compute_attributes(:one).vm_attrs, host.compute_attributes
  end

  test "compute attributes are populated by hardware profile passed to host" do
    # hostgroups(:one) fixture has compute_profiles(:common)
    host = Host.new :name => "myhost", :compute_resource_id => compute_resources(:ec2).id, :compute_profile_id => compute_profiles(:two).id, :managed => true, :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :architecture => architectures(:x86_64), :environment => environments(:production)
    host.expects(:queue_compute_create)
    assert host.valid?, host.errors.full_messages.to_sentence
    assert_equal compute_attributes(:three).vm_attrs, host.compute_attributes
  end

end # end of context "location or organizations are not enabled"

  test "#capabilities returns capabilities from compute resource" do
    host = hosts(:one)
    host.compute_resource.expects(:capabilities).returns([:build, :image])
    assert_equal [:build, :image], host.capabilities
  end

  test "#capabilities on bare metal returns build" do
    host = hosts(:one)
    host.compute_resource = nil
    assert_equal [:build], host.capabilities
  end

  test "#provision_method cannot be set to invalid type" do
    host = hosts(:one)
    host.provision_method = 'foobar'
    host.stubs(:provision_method_in_capabilities).returns(true)
    host.valid?
    assert host.errors[:provision_method].include?('is unknown')
  end

  test "#provision_method doesn't matter on unmanaged hosts" do
    host = hosts(:one)
    host.managed = false
    host.provision_method = 'foobar'
    assert host.valid?
  end

  test "#provision_method must be within capabilities" do
    host = hosts(:one)
    host.provision_method = 'image'
    host.expects(:capabilities).returns([:build])
    host.valid?
    assert host.errors[:provision_method].include?('is an unsupported provisioning method')
  end

  test "#provision_method cannot be updated for existing host" do
    host = hosts(:one)
    host.provision_method = 'image'
    refute host.save
    assert host.errors[:provision_method].include?("can't be updated after host is provisioned")
  end

  test "#image_build? must be true when provision_method is image" do
    host = hosts(:one)
    host.provision_method = 'image'
    assert host.image_build?
    refute host.pxe_build?
  end

  test "#pxe_build? must be true when provision_method is build" do
    host = hosts(:one)
    host.provision_method = 'build'
    assert host.pxe_build?
    refute host.image_build?
  end

  test "classes_in_groups should return the puppetclasses of a config group only if it is in host environment" do
    # config_groups(:one) and (:two) belongs to hosts(:one)
    host = hosts(:one)
    group_classes = host.classes_in_groups
    # four classes in config groups, all are in same environment
    assert_equal 4, (config_groups(:one).puppetclasses + config_groups(:two).puppetclasses).uniq.count
    assert_equal ['chkmk', 'nagios', 'pam', 'auth'].sort, group_classes.map(&:name).sort
  end

  test "should return all classes for environment only" do
    # config_groups(:one) and (:two) belongs to hosts(:one)
    host = hosts(:one)
    all_classes = host.classes
    # four classes in config groups plus one manually added
    assert_equal 5, all_classes.count
    assert_equal ['base', 'chkmk', 'nagios', 'pam', 'auth'].sort, all_classes.map(&:name).sort
    assert_equal all_classes, host.all_puppetclasses
  end

  test "search hostgroups by config group" do
    config_group = config_groups(:one)
    hosts = Host::Managed.search_for("config_group = #{config_group.name}")
  #  assert_equal 1, hosts.count
    assert_equal ["my5name.mydomain.net", "sdhcp.mydomain.net"].sort, hosts.map(&:name).sort
  end

  test "parent_classes should return parent_classes if host has hostgroup and environment are the same" do
    host = hosts(:sp_dhcp)
    assert host.hostgroup
    refute_empty host.parent_classes
    assert_equal host.parent_classes, host.hostgroup.classes
  end

  test "parent_classes should not return parent classes that do not match environment" do
    host = hosts(:sp_dhcp)
    assert host.hostgroup
    # update environment of host to be different
    host.hostgroup.update_attribute(:environment_id, environments(:testing).id)
    refute_empty host.parent_classes
    refute_equal host.environment, host.hostgroup.environment
    refute_equal host.parent_classes, host.hostgroup.classes
  end

  test "parent_classes should return empty array if host does not have hostgroup" do
    host = hosts(:one)
    assert_nil host.hostgroup
    assert_empty host.parent_classes
  end

  test "parent_config_groups should return parent config_groups if host has hostgroup" do
    host = hosts(:sp_dhcp)
    assert host.hostgroup
    assert_equal host.parent_config_groups, host.hostgroup.config_groups
  end

  test "parent_config_groups should return empty array if host has no hostgroup" do
    host = hosts(:one)
    refute host.hostgroup
    assert_empty host.parent_config_groups
  end

  test "individual puppetclasses added to host (that can be removed) does not include classes that are included by config group" do
    host = hosts(:one)
    host.puppetclasses << puppetclasses(:five)
    assert_equal ['base', 'nagios'].sort, host.puppetclasses.map(&:name).sort
    assert_equal ['base'], host.individual_puppetclasses.map(&:name)
  end

  test "available_puppetclasses should return all if no environment" do
    host = hosts(:one)
    host.update_attribute(:environment_id, nil)
    assert_equal Puppetclass.scoped, host.available_puppetclasses
  end

  test "available_puppetclasses should return environment-specific classes" do
    host = hosts(:one)
    refute_equal Puppetclass.scoped, host.available_puppetclasses
    assert_equal host.environment.puppetclasses.sort, host.available_puppetclasses.sort
  end

  test "available_puppetclasses should return environment-specific classes (and that are NOT already inherited by parent)" do
    host = hosts(:sp_dhcp)
    refute_equal Puppetclass.scoped, host.available_puppetclasses
    refute_equal host.environment.puppetclasses.sort, host.available_puppetclasses.sort
    assert_equal (host.environment.puppetclasses - host.parent_classes).sort, host.available_puppetclasses.sort
  end

  test "#info ENC YAML uses all_puppetclasses for non-parameterized output" do
    Setting[:Parametrized_Classes_in_ENC] = false
    myclass = mock('myclass')
    myclass.expects(:name).returns('myclass')
    host = FactoryGirl.build(:host)
    host.expects(:all_puppetclasses).returns([myclass])
    enc = host.info
    assert_kind_of Hash, enc
    assert_equal ['myclass'], enc['classes']
  end

  test "#info ENC YAML uses Classification::ClassParam for parameterized output" do
    Setting[:Parametrized_Classes_in_ENC] = true
    Setting[:Enable_Smart_Variables_in_ENC] = true
    host = FactoryGirl.build(:host)
    classes = {'myclass' => {'myparam' => 'myvalue'}}
    classification = mock('Classification::ClassParam')
    classification.expects(:enc).returns(classes)
    Classification::ClassParam.expects(:new).with(:host => host).returns(classification)
    enc = host.info
    assert_kind_of Hash, enc
    assert_equal classes, enc['classes']
  end

  test 'clone host including its relationships' do
    host = hosts(:one)
    copy = host.clone
    assert_equal host.host_classes.map(&:puppetclass_id), copy.host_classes.map(&:puppetclass_id)
    assert_equal host.host_parameters.map(&:name), copy.host_parameters.map(&:name)
    assert_equal host.host_parameters.map(&:value), copy.host_parameters.map(&:value)
    assert_equal host.host_config_groups.map(&:config_group_id), copy.host_config_groups.map(&:config_group_id)
  end

  test 'clone host should not copy name, system fields (mac, ip, etc) or interfaces' do
    host = hosts(:one)
    copy = host.clone
    assert copy.name.blank?
    assert copy.mac.blank?
    assert copy.ip.blank?
    assert copy.uuid.blank?
    assert copy.certname.blank?
    assert copy.last_report.blank?
    assert_empty copy.interfaces
  end

  test 'fqdn of host with period in name returns just name with no concatenation of domain' do
    host = hosts(:one)
    assert_equal "my5name.mydomain.net", host.name
    assert_equal host.name, host.fqdn
  end

  test 'fqdn of host without period in name returns name concatenated with domain' do
    host = hosts(:otherfullhost)
    assert_equal "otherfullhost", host.name
    assert_equal "mydomain.net", host.domain.name
    assert_equal 'otherfullhost.mydomain.net', host.fqdn
  end

  test 'fqdn of host period and no domain returns just name' do
    host = Host::Managed.new(:name => name = "dhcp123")
    assert_equal "dhcp123", host.fqdn
  end

  test 'fqdn_changed? should be true if name changes' do
    host = hosts(:one)
    host.stubs(:name_changed?).returns(true)
    host.stubs(:domain_id_changed?).returns(false)
    assert host.fqdn_changed?
  end

  test 'fqdn_changed? should be true if domain changes' do
    host = hosts(:one)
    host.stubs(:name_changed?).returns(false)
    host.stubs(:domain_id_changed?).returns(true)
    assert host.fqdn_changed?
  end

  test 'fqdn_changed? should be true if name and domain change' do
    host = hosts(:one)
    host.stubs(:name_changed?).returns(true)
    host.stubs(:domain_id_changed?).returns(true)
    assert host.fqdn_changed?
  end

  test 'clone should create compute_attributes for VM-based hosts' do
    copy = hosts(:one).clone
    assert !copy.compute_attributes.nil?
  end

  test 'clone should NOT create compute_attributes for bare-metal host' do
    copy = hosts(:bare_metal).clone
    assert copy.compute_attributes.nil?
  end

  test 'facts are deleted when build set to true' do
    host = FactoryGirl.create(:host, :with_facts)
    assert_present host.fact_values
    refute host.build?
    host.update_attributes(:build => true)
    assert_empty host.fact_values.reload
  end

  test 'reports are deleted when build set to true' do
    host = FactoryGirl.create(:host, :with_reports)
    assert_present host.reports
    refute host.build?
    host.update_attributes(:build => true)
    assert_empty host.reports.reload
  end

  test 'changing name with a fqdn should rename lookup_value matcher' do
    host = hosts(:one)
    lookup_value_id = lookup_values(:one).id
    assert_equal "fqdn=#{host.fqdn}", LookupValue.find(lookup_value_id).match

    host.name = "my5name-new.mydomain.net"
    host.save!
    assert_equal "fqdn=my5name-new.mydomain.net", LookupValue.find(lookup_value_id).match
  end

  test 'changing only name should rename lookup_value matcher' do
    host = hosts(:one)
    lookup_value_id = lookup_values(:one).id
    assert_equal LookupValue.find(lookup_value_id).match, "fqdn=#{host.fqdn}"

    host.name = "my5name-new"
    host.save!
    assert_equal "fqdn=my5name-new.mydomain.net", LookupValue.find(lookup_value_id).match
  end

  test 'changing host domain should rename lookup_value matcher' do
    host = hosts(:one)
    lookup_value_id = lookup_values(:one).id
    assert_equal LookupValue.find(lookup_value_id).match, "fqdn=#{host.fqdn}"

    host.domain = domains(:yourdomain)
    host.save!
    assert_equal "fqdn=my5name.yourdomain.net", LookupValue.find(lookup_value_id).match
  end

  describe '#overwrite=' do
    context 'false' do
      [:false, 'false', false].each do |v|
        test "when setting to #{v.inspect}" do
          refute FactoryGirl.build(:host, :overwrite => v).overwrite?
        end
      end
    end

    context 'true' do
      [:true, 'true', true].each do |v|
        test "when setting to #{v.inspect}" do
          assert FactoryGirl.build(:host, :overwrite => v).overwrite?
        end
      end
    end
  end

  private

  def parse_json_fixture(relative_path)
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + relative_path)))
  end

  def setup_host_with_nic_parser(nic_attributes)
    host = FactoryGirl.create(:host, :hostgroup => FactoryGirl.create(:hostgroup))
    hash = { (nic_attributes.delete(:identifier) || :eth0) => nic_attributes
           }.with_indifferent_access
    parser = stub(:interfaces => hash, :ipmi_interface => {})
    [host, parser]
  end

  def setup_host_with_ipmi_parser(ipmi_attributes)
    host = FactoryGirl.create(:host, :hostgroup => FactoryGirl.create(:hostgroup))
    hash = ipmi_attributes.with_indifferent_access
    parser = stub(:ipmi_interface => hash, :interfaces => {})
    [host, parser]
  end

end
