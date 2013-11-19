require 'test_helper'

class SystemTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = User.find_by_login "admin"
    Setting[:token_duration] = 0
  end

  test "should not save without a systemname" do
    system = System.new
    assert !system.save
  end

  test "should fix mac address hyphens" do
    system = System.create :name => "mysystem", :mac => "aa-bb-cc-dd-ee-ff"
    assert_equal "aa:bb:cc:dd:ee:ff", system.mac
  end

  test "should fix mac address" do
    system = System.create :name => "mysystem", :mac => "aabbccddeeff"
    assert_equal "aa:bb:cc:dd:ee:ff", system.mac
  end

  test "should keep valid mac address" do
    system = System.create :name => "mysystem", :mac => "aa:bb:cc:dd:ee:ff"
    assert_equal "aa:bb:cc:dd:ee:ff", system.mac
  end

  test "should fix ip address if a leading zero is used" do
    system = System.create :name => "mysystem", :mac => "aabbccddeeff", :ip => "123.01.02.03"
    assert_equal "123.1.2.3", system.ip
  end

  test "should add domain name to systemname" do
    system = System.create :name => "mysystem", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "mysystem.company.com", system.name
  end

  test "should not add domain name to systemname if it already include it" do
    system = System.create :name => "mysystem.COMPANY.COM", :mac => "aabbccddeeff", :ip => "123.1.2.3",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "mysystem.COMPANY.COM", system.name
  end

  test "should add systemname if it contains domain name" do
    system = System.create :name => "mysystem.company.com", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "mysystem.company.com", system.name
  end

  test "should not append domainname to fqdn" do
    system = System.create :name => "mysystem.sub.comp.net", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com"),
      :certname => "mysystem.sub.comp.net",
      :managed => false
    assert_equal "mysystem.sub.comp.net", system.name
  end

  test "should save systems with full stop in their name" do
    system = System.create :name => "my.system.company.com", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "my.system.company.com", system.name
  end


  test "should be able to save system" do
    system = System.create :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "2.3.4.3",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :puppet_proxy => smart_proxies(:puppetmaster),
      :environment => environments(:production), :disk => "empty partition"
    assert system.valid?
    assert !system.new_record?
  end

  test "non-admin user should be able to create system with new lookup value" do
    User.current = users(:one)
    User.current.roles << [roles(:manager)]
    assert_difference('LookupValue.count') do
      assert System.create! :name => "abc.mydomain.net", :mac => "aabbecddeeff", :ip => "2.3.4.3",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :puppet_proxy => smart_proxies(:puppetmaster),
      :environment => environments(:production), :disk => "empty partition",
      :lookup_values_attributes => {"new_123456" => {"lookup_key_id" => lookup_keys(:complex).id, "value"=>"some_value", "match" => "fqdn=abc.mydomain.net"}}
    end
  end

  test "should import facts from json stream" do
    h=System.new(:name => "sinn1636.lan")
    h.disk = "!" # workaround for now
    assert h.importFacts(JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.json")))['facts'])
  end

  test "should import facts from json of a new system when certname is not specified" do
    refute System.find_by_name('sinn1636.lan')
    raw = parse_json_fixture('/facts.json')
    assert System.importSystemAndFacts(raw['name'], raw['facts'])
    assert System.find_by_name('sinn1636.lan')
  end

  test "should downcase systemname parameter from json of a new system" do
    raw = parse_json_fixture('/facts_with_caps.json')
    assert System.importSystemAndFacts(raw['name'], raw['facts'])
    assert System.find_by_name('sinn1636.lan')
  end

  test "should import facts idempotently" do
    raw = parse_json_fixture('/facts_with_caps.json')
    assert System.importSystemAndFacts(raw['name'], raw['facts'])
    value_ids = System.find_by_name('sinn1636.lan').fact_values.map(&:id)
    assert System.importSystemAndFacts(raw['name'], raw['facts'])
    assert_equal value_ids, System.find_by_name('sinn1636.lan').fact_values.map(&:id)
  end

  test "should find a system by certname not fqdn when provided" do
    System.new(:name => 'sinn1636.fail', :certname => 'sinn1636.lan.cert').save(:validate => false)
    assert System.find_by_name('sinn1636.fail').ip.nil?
    # systemname in the json is sinn1636.lan, so if the facts have been updated for
    # this system, it's a successful identification by certname
    raw = parse_json_fixture('/facts_with_certname.json')
    assert System.importSystemAndFacts(raw['name'], raw['facts'], raw['certname'])
    assert_equal '10.35.27.2', System.find_by_name('sinn1636.fail').ip
  end

  test "should update certname when system is found by systemname and certname is provided" do
    System.new(:name => 'sinn1636.lan', :certname => 'sinn1636.cert.fail').save(:validate => false)
    assert_equal 'sinn1636.cert.fail', System.find_by_name('sinn1636.lan').certname
    raw = parse_json_fixture('/facts_with_certname.json')
    assert System.importSystemAndFacts(raw['name'], raw['facts'], raw['certname'])
    assert_equal 'sinn1636.lan.cert', System.find_by_name('sinn1636.lan').certname
  end

  test "system is not created when uploading facts if setting is false" do
    Setting[:create_new_system_when_facts_are_uploaded] = false
    assert_equal false, Setting[:create_new_system_when_facts_are_uploaded]
    raw = parse_json_fixture('/facts_with_certname.json')
    assert System.importSystemAndFacts(raw['name'], raw['facts'], raw['certname'])
    system = System.find_by_name('sinn1636.lan')
    Setting[:create_new_system_when_facts_are_uploaded] =
        Setting.find_by_name("create_new_system_when_facts_are_uploaded").default
    assert_nil system
  end

  test "system is not created when receiving a report if setting is false" do
    Setting[:create_new_system_when_report_is_uploaded] = false
    assert_equal false, Setting[:create_new_system_when_report_is_uploaded]
    Report.import parse_json_fixture("/../fixtures/report-no-logs.json")
    system = System.find_by_name('builder.fm.example.net')
    Setting[:create_new_system_when_report_is_uploaded] =
        Setting.find_by_name("create_new_system_when_facts_are_uploaded").default
    assert_nil system
  end

  test "should not save if neither ptable or disk are defined when the system is managed" do
    if unattended?
      system = System.create :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "2.4.4.03",
        :domain => domains(:mydomain), :operatingsystem => Operatingsystem.first, :subnet => subnets(:one),
        :architecture => Architecture.first, :environment => Environment.first, :managed => true
      assert !system.valid?
    end
  end

  test "should save if neither ptable or disk are defined when the system is not managed" do
    system = System.create :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => false
    assert system.valid?
  end

  test "should save if ptable is defined" do
    system = System.create :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :ptable => Ptable.first
    assert !system.new_record?
  end

  test "should save if disk is defined" do
    system = System.create :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one),
      :architecture => architectures(:x86_64), :environment => environments(:production), :disk => "aaa", :puppet_proxy => smart_proxies(:puppetmaster)
    assert !system.new_record?
  end

  test "should not save if IP is not in the right subnet" do
    if unattended?
      system = System.create :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "123.05.02.03",
        :domain => domains(:mydomain), :operatingsystem => Operatingsystem.first, :subnet => subnets(:one), :managed => true,
        :architecture => Architecture.first, :environment => Environment.first, :ptable => Ptable.first, :puppet_proxy => smart_proxies(:puppetmaster)
      assert !system.valid?
    end
  end

  test "should save if owner_type is User or Usergroup" do
    system = System.new :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => true,
      :owner_type => "User"
    assert system.valid?
  end

  test "should not save if owner_type is not User or Usergroup" do
    system = System.new :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => true,
      :owner_type => "UserGr(up" # should be Usergroup
    assert !system.valid?
  end

  test "should save if owner_type is empty and System is unmanaged" do
    system = System.new :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => false
    assert system.valid?
  end

  test "should import from external nodes output" do
    # create a dummy node
    Parameter.destroy_all
    system = System.create :name => "myfullsystem", :mac => "aabbacddeeff", :ip => "2.3.4.12",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one),
      :architecture => architectures(:x86_64), :environment => environments(:global_puppetmaster), :disk => "aaa",
      :puppet_proxy => smart_proxies(:puppetmaster)

    # dummy external node info
    nodeinfo = {"environment" => "global_puppetmaster",
      "parameters"=> {"puppetmaster"=>"puppet", "MYVAR"=>"value", "port" => "80",
        "ssl_port" => "443", "foreman_env"=> "global_puppetmaster", "owner_name"=>"Admin User",
        "root_pw"=>"xybxa6JUkz63w", "owner_email"=>"admin@someware.com"},
      "classes"=>["apache", "base"]}

    system.importNode nodeinfo

    assert_equal system.info, nodeinfo
  end

  test "show be enabled by default" do
    system = System.create :name => "mysystem", :mac => "aabbccddeeff"
    assert system.enabled?
  end

  test "system can be disabled" do
    system = System.create :name => "mysystem", :mac => "aabbccddeeff"
    system.enabled = false
    system.save
    assert system.disabled?
  end

  def setup_user_and_system
    @one            = users(:one)
    @one.system_groups.destroy_all
    @one.domains.destroy_all
    @one.user_facts.destroy_all
    @one.save!
    @system           = systems(:one)
    @system.owner     = users(:two)
    @system.save!
    User.current    = @one
  end

  def setup_filtered_user
    # Can't use `setup_user_and_system` as it deletes the UserFacts
    @one             = users(:one)
    @one.system_groups.destroy_all
    @one.domains.destroy_all
    @one.user_facts  = [user_facts(:one)]
    @one.facts_andor = "and"
    @one.save!
    User.current    = @one
  end

  test "system cannot be edited without permission" do
    setup_user_and_system
    as_admin do
      @one.roles = [Role.find_by_name("Viewer")]
    end
    assert !@system.update_attributes(:comment => "blahblahblah")
    assert_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "any system can be edited when permitted" do
    setup_user_and_system
    as_admin do
      @one.roles      = [Role.find_by_name("Edit systems")]
    end
    assert @system.update_attributes(:comment => "blahblahblah")
    assert_no_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "systems can be edited when domains permit" do
    setup_user_and_system
    as_admin do
      @one.roles      = [Role.find_by_name("Edit systems")]
      @one.domains    = [Domain.find_by_name("mydomain.net")]
    end
    assert @system.update_attributes(:comment => "blahblahblah")
    assert_no_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "systems cannot be edited when domains deny" do
    setup_user_and_system
    as_admin do
      @one.roles      = [Role.find_by_name("Edit systems")]
      @one.domains    = [Domain.find_by_name("yourdomain.net")]
    end
    assert !@system.update_attributes(:comment => "blahblahblah")
    assert_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "system cannot be created without permission" do
    setup_user_and_system
    as_admin do
      @one.roles = [Role.find_by_name("Viewer")]
    end
    system = System.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "2.3.4.09",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production), :puppet_proxy => smart_proxies(:puppetmaster),
                       :subnet => subnets(:one), :disk => "empty partition")
    assert system.new_record?
    assert_match /do not have permission/, system.errors.full_messages.join("\n")
  end

  test "any system can be created when permitted" do
    setup_user_and_system
    as_admin do
      @one.roles = [Role.find_by_name("Create systems")]
    end
    system = System.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "2.3.4.11",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),  :puppet_proxy => smart_proxies(:puppetmaster),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :subnet => subnets(:one), :disk => "empty partition")
    assert !system.new_record?
    assert_no_match /do not have permission/, system.errors.full_messages.join("\n")
  end

  test "systems can be created when system_groups permit" do
    setup_user_and_system
    as_admin do
      @one.roles      = [Role.find_by_name("Create systems")]
      @one.system_groups = [SystemGroup.find_by_name("Common")]
    end
    system = System.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "2.3.4.4",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :subnet => subnets(:one),
                       :disk => "empty partition", :system_group => system_groups(:common))
    assert !system.new_record?
    assert_no_match /do not have permission/, system.errors.full_messages.join("\n")
  end

  test "systems cannot be created when system_groups deny" do
    setup_user_and_system
    as_admin do
      @one.roles      = [Role.find_by_name("Create systems")]
      @one.system_groups = [SystemGroup.find_by_name("Unusual")]
    end
    system = System.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "2.3.4.9",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :subnet => subnets(:one),
                       :disk => "empty partition", :system_group => system_groups(:common))
    assert system.new_record?
    assert_match /do not have permission/, system.errors.full_messages.join("\n")
  end

  test "system cannot be destroyed without permission" do
    setup_user_and_system
    as_admin do
      @one.roles = [Role.find_by_name("Viewer")]
    end
    assert !@system.destroy
    assert_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "any system can be destroyed when permitted" do
    setup_user_and_system
    as_admin do
      @one.roles = [Role.find_by_name("Destroy systems")]
      @system.system_classes.delete_all
      assert @system.destroy
    end
    assert_no_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "systems can be destroyed when ownership permits" do
    setup_user_and_system
    as_admin do
      @one.roles = [Role.find_by_name("Destroy systems")]
      @system.update_attribute :owner,  users(:one)
      @system.system_classes.delete_all
      assert @system.destroy
    end
    assert_no_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "systems cannot be destroyed when ownership denies" do
    setup_user_and_system
    as_admin do
      @one.roles   = [Role.find_by_name("Destroy systems")]
      @one.domains = [domains(:yourdomain)] # This does not grant access but does ensure that access is constrained
      @system.owner  = users(:two)
      @system.save!
    end
    assert !@system.destroy
    assert_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "fact filters restrict the my_systems scope" do
    setup_filtered_user
    assert_equal 1, System.my_systems.count
    assert_equal 'my5name.mydomain.net', System.my_systems.first.name
  end

  test "sti types altered in memory with becomes are still contained in my_systems scope" do
    class System::Valid < System::Base ; belongs_to :domain ; end
    h = System::Valid.new :name => "mytestvalidsystem.foo.com"
    setup_user_and_system
    as_admin do
      @one.domains = [domains(:yourdomain)] # ensure it matches the user filters
      h.update_attribute :domain,  domains(:yourdomain)
    end
    h_new = h.becomes(System::Managed) # change the type to break normal AR `==` method
    assert System::Base.my_systems.include?(h_new)
  end

  test "system can be edited when user fact filter permits" do
    setup_filtered_user
    as_admin do
      @one.roles  = [Role.find_by_name("Edit systems")]
      @system       = systems(:one)
      @system.owner = users(:two)
      @system.save!
    end
    assert @system.update_attributes(:comment => "blahblahblah")
    assert_no_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "system cannot be edited when user fact filter denies" do
    setup_filtered_user
    as_admin do
      @one.roles  = [Role.find_by_name("Edit systems")]
      @system       = systems(:two)
      @system.owner = users(:two)
      @system.save!
    end
    assert !@system.update_attributes(:comment => "blahblahblah")
    assert_match /do not have permission/, @system.errors.full_messages.join("\n")
  end

  test "a fqdn System should be assigned to a domain if such domain exists" do
    domain = domains(:mydomain)
    system = System.create :name => "system.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one),
      :architecture => architectures(:x86_64), :environment => environments(:production), :disk => "aaa"
    system.valid?
    assert_equal domain, system.domain
  end

  test "a system should retrieve its gPXE template if it is associated to the correct env and system group" do
    system = System.create :name => "system.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => Operatingsystem.find_by_name("centos"), :subnet => subnets(:one), :system_group => SystemGroup.find_by_name("common"),
      :architecture => Architecture.first, :environment => Environment.find_by_name("production"), :disk => "aaa"

    assert_equal ConfigTemplate.find_by_name("MyString"), system.configTemplate({:kind => "gPXE"})
  end

  test "a system should retrieve its provision template if it is associated to the correct system group only" do
    system = System.create :name => "system.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => Operatingsystem.find_by_name("centos"), :subnet => subnets(:one), :system_group => SystemGroup.find_by_name("common"),
      :architecture => Architecture.first, :environment => Environment.find_by_name("production"), :disk => "aaa"

    assert_equal ConfigTemplate.find_by_name("MyString2"), system.configTemplate({:kind => "provision"})
  end

  test "a system should retrieve its script template if it is associated to the correct OS only" do
    system = System.create :name => "system.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => Operatingsystem.find_by_name("centos"), :subnet => subnets(:one), :system_group => SystemGroup.find_by_name("common"),
      :architecture => Architecture.first, :environment => Environment.find_by_name("production"), :disk => "aaa"

    assert_equal ConfigTemplate.find_by_name("MyScript"), system.configTemplate({:kind => "script"})
  end

 test "a system should retrieve its finish template if it is associated to the correct environment only" do
    system = System.create :name => "system.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => Operatingsystem.find_by_name("centos"), :subnet => subnets(:one), :system_group => SystemGroup.find_by_name("common"),
      :architecture => Architecture.first, :environment => Environment.find_by_name("production"), :disk => "aaa"

    assert_equal ConfigTemplate.find_by_name("MyFinish"), system.configTemplate({:kind => "finish"})
  end

  test "handle_ca must not perform actions when the manage_puppetca setting is false" do
    h = systems(:one)
    Setting[:manage_puppetca] = false
    h.expects(:initialize_puppetca).never()
    h.expects(:setAutosign).never()
    assert h.handle_ca
  end

  test "handle_ca must not perform actions when no Puppet CA proxy is associated" do
    h = systems(:one)
    Setting[:manage_puppetca] = true
    refute h.puppetca?
    h.expects(:initialize_puppetca).never()
    assert h.handle_ca
  end

  test "handle_ca must call initialize, delete cert and add autosign methods" do
    h = systems(:dhcp)
    Setting[:manage_puppetca] = true
    assert h.puppetca?
    h.expects(:initialize_puppetca).returns(true)
    h.expects(:delCertificate).returns(true)
    h.expects(:setAutosign).returns(true)
    assert h.handle_ca
  end

  test "if the user toggles off the use_uuid_for_certificates option, revoke the UUID and autosign the systemname" do
    h = systems(:dhcp)
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

  test "custom_disk_partition_with_erb" do
    h = systems(:one)
    h.disk = "<%= 1 + 1 %>"
    assert h.save
    assert h.disk.present?
    assert_equal "2", h.diskLayout
  end

  test "models are updated when system.model has no value" do
    h = systems(:one)
    f = fact_names(:kernelversion)
    as_admin do
      fact_value = FactValue.where(:fact_name_id => f.id).first
      fact_value.update_attributes!(:value => "superbox")
    end
    assert_difference('Model.count') do
      facts = JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.json")))
      h.populateFieldsFromFacts facts['facts']
    end
  end

  test "system_group should set default values when none exists" do
    # should set os, but not arch
    hg = system_groups(:common)
    h  = System.new
    h.system_group = hg
    h.architecture = architectures(:sparc)
    assert !h.valid?
    assert_equal hg.operatingsystem, h.operatingsystem
    assert_not_equal hg.architecture , h.architecture
    assert_equal h.architecture, architectures(:sparc)
  end

  test "system os attributes must be associated with the system os" do
    h = systems(:redhat)
    h.managed = true
    h.architecture = architectures(:sparc)
    assert !h.os.architectures.include?(h.arch)
    assert !h.valid?
    assert_equal ["#{h.architecture} does not belong to #{h.os} operating system"], h.errors[:architecture_id]
  end

  test "system puppet classes must belong to the system environment" do
    h = systems(:redhat)

    pc = puppetclasses(:three)
    h.puppetclasses << pc
    assert !h.environment.puppetclasses.map(&:id).include?(pc.id)
    assert !h.valid?
    assert_equal ["#{pc} does not belong to the #{h.environment} environment"], h.errors[:puppetclasses]
  end

  test "when changing system environment, its puppet classes should be verified" do
    h = systems(:two)
    pc = puppetclasses(:one)
    h.puppetclasses << pc
    assert h.save
    h.environment = environments(:testing)
    assert !h.save
    assert_equal ["#{pc} does not belong to the #{h.environment} environment"], h.errors[:puppetclasses]
  end

  test "name should be lowercase" do
    h = systems(:redhat)
    assert h.valid?
    h.name.upcase!
    assert !h.valid?
  end

  test "should allow to save root pw" do
    h = systems(:redhat)
    pw = h.root_pass
    h.root_pass = "token"
    h.system_group = nil
    assert h.save
    assert_not_equal pw, h.root_pass
  end

  test "should allow to revert to default root pw" do
    h = systems(:redhat)
    h.root_pass = "token"
    assert h.save
    h.root_pass = ""
    assert h.save
    assert_equal h.root_pass, Setting.root_pass
  end

  test "should generate a random salt when saving root pw" do
    h = systems(:redhat)
    pw = h.root_pass
    h.root_pass = "token"
    h.system_group = nil
    assert h.save
    first = h.root_pass

    # Check it's a $.$....$...... enhanced style password
    assert_equal 4, first.split('$').count
    assert first.split('$')[2].size >= 8

    # Check it changes
    h.root_pass = "token"
    assert h.save
    assert_not_equal first.split('$')[2], h.root_pass.split('$')[2]
  end

  test "should pass through existing salt when saving root pw" do
    h = systems(:redhat)
    pass = "$1$jmUiJ3NW$bT6CdeWZ3a6gIOio5qW0f1"
    h.root_pass = pass
    h.system_group = nil
    assert h.save
    assert_equal pass, h.root_pass
  end

  test "should use system_group root password" do
    h = systems(:redhat)
    h.root_pass = nil
    h.system_group = system_groups(:common)
    assert h.save
    h.system_group.update_attribute(:root_pass, "abc")
    assert h.root_pass.present? && h.root_pass != Setting[:root_pass]
  end

  test "should use a nested system_group parent root password" do
    h = systems(:redhat)
    h.root_pass = nil
    h.system_group = hg = system_groups(:common)
    assert h.save
    hg.parent = system_groups(:unusual)
    hg.root_pass = nil
    hg.parent.update_attribute(:root_pass, "abc")
    hg.save
    assert h.root_pass.present? && h.root_pass != Setting[:root_pass]
  end

  test "should use settings root password" do
    h = systems(:redhat)
    h.root_pass = nil
    h.system_group = nil
    assert h.save
    assert h.root_pass.present? && h.root_pass == Setting[:root_pass]
  end


  test "should save uuid on managed systems" do
    Setting[:use_uuid_for_certificates] = true
    system = System.create :name => "mysystem1", :mac => "aabbecddeeff", :ip => "2.3.4.3", :system_group => system_groups(:common), :managed => true
    assert system.valid?
    assert !system.new_record?
    assert_not_nil system.certname
    assert_not_equal system.name, system.certname
  end

  test "should not save uuid on non managed systems" do
    Setting[:use_uuid_for_certificates] = true
    system = System.create :name => "mysystem1", :mac => "aabbecddeeff", :ip => "2.3.4.3", :system_group => system_groups(:common), :managed => false
    assert system.valid?
    assert !system.new_record?
    assert_equal system.name, system.certname
  end

  test "should not save uuid when settings disable it" do
    Setting[:use_uuid_for_certificates] = false
    system = System.create :name => "mysystem1", :mac => "aabbecddeeff", :ip => "2.3.4.3", :system_group => system_groups(:common), :managed => false
    assert system.valid?
    assert !system.new_record?
    assert_equal system.name, system.certname
  end

  test "all whitespace should be removed from systemname" do
    system = System.create :name => "my system 1	", :mac => "aabbecddeeff", :ip => "2.3.4.3", :system_group => system_groups(:common), :managed => false
    assert system.valid?
    assert !system.new_record?
    assert_equal "mysystem1.mydomain.net", system.name
  end

  test "assign a system to a location" do
    system = System.create :name => "system 1", :mac => "aabbecddeeff", :ip => "5.5.5.5", :system_group => system_groups(:common), :managed => false
    location = Location.create :name => "New York"

    system.location_id = location.id
    assert system.save!
  end

  test "update a system's location" do
    system = System.create :name => "system 1", :mac => "aabbccddee", :ip => "5.5.5.5", :system_group => system_groups(:common), :managed => false
    original_location = Location.create :name => "New York"

    system.location_id = original_location.id
    assert system.save!
    assert system.location_id = original_location.id

    new_location = Location.create :name => "Los Angeles"
    system.location_id = new_location.id
    assert system.save!
    assert system.location_id = new_location.id
  end

  test "assign a system to an organization" do
    system = System.create :name => "system 1", :mac => "aabbecddeeff", :ip => "5.5.5.5", :system_group => system_groups(:common), :managed => false
    organization = Organization.create :name => "Systeming client 1"

    system.organization_id = organization.id
    assert system.save!
  end

  test "assign a system to both a location and an organization" do
    system = System.create :name => "system 1", :mac => "aabbccddeeff", :ip => "5.5.5.5", :system_group => system_groups(:common), :managed => false
    location = Location.create :name => "Tel Aviv"
    organization = Organization.create :name => "Systeming client 1"

    system.location_id = location.id
    system.organization_id = organization.id

    assert system.save!
  end


  test "should have only one bootable interface" do
    h = systems(:redhat)
    assert_equal 0, h.interfaces.count
    bootable = Nic::Bootable.create! :system => h, :name => "dummy-bootable", :ip => "2.3.4.102", :mac => "aa:bb:cd:cd:ee:ff",
                                     :subnet => h.subnet, :type => 'Nic::Bootable', :domain => h.domain
    assert_equal 1, h.interfaces.count
    h.interfaces_attributes = [{:name => "dummy-bootable2", :ip => "2.3.4.103", :mac => "aa:bb:cd:cd:ee:ff",
                                :subnet_id => h.subnet_id, :type => 'Nic::Bootable', :domain_id => h.domain_id }]
    assert !h.valid?
    assert_equal "Only one bootable interface is allowed", h.errors['interfaces.type'][0]
    assert_equal 1, h.interfaces.count
  end

  # Token tests

  test "built should clean tokens" do
    Setting[:token_duration] = 30
    h = systems(:one)
    h.create_token(:value => "aaaaaa", :expires => Time.now)
    assert_equal Token.all.size, 1
    h.expire_tokens
    assert_equal Token.all.size, 0
  end

  test "built should clean tokens even when tokens are disabled" do
    Setting[:token_duration] = 0
    h = systems(:one)
    h.create_token(:value => "aaaaaa", :expires => Time.now)
    assert_equal Token.all.size, 1
    h.expire_tokens
    assert_equal Token.all.size, 0
  end

  test "systems should be able to retrieve their token if one exists" do
    Setting[:token_duration] = 30
    h = systems(:one)
    assert_equal Token.first, h.token
  end

  test "token should return false when tokens are disabled or invalid" do
    Setting[:token_duration] = 0
    h = systems(:one)
    assert_equal h.token, nil
    Setting[:token_duration] = 30
    h = systems(:one)
    assert_equal h.token, nil
  end

  test "can search systems by system_group" do
    #setup - add parent to system_group :common (not in fixtures, since no field parent_id)
    system_group = system_groups(:db)
    parent_system_group = system_groups(:common)
    system_group.parent_id = parent_system_group.id
    assert system_group.save!

    # search systems by system_group label
    systems = System.search_for("system_group_fullname = #{system_group.label}")
    assert_equal systems.count, 1  #system_db in systems.yml
    assert_equal systems.first.system_group_id, system_group.id
  end

  test "non-admin user with edit_systems permission can update interface" do
    @one = users(:one)
    # add permission for user :one
    as_admin do
      role = Role.find_or_create_by_name :name => "testing_role"
      role.permissions = [:edit_systems]
      @one.roles = [role]
      @one.save!
    end
    h = systems(:one)
    assert h.interfaces.create :mac => "cabbccddeeff", :system => systems(:one), :type => 'Nic::BMC',
                               :provider => "IPMI", :username => "root", :password => "secret", :ip => "10.35.19.35"
    as_user :one do
      assert h.update_attributes!("interfaces_attributes" => {"0" => {"mac"=>"59:52:10:1e:45:16"}})
    end
  end

  test "can auto-complete searches by system name" do
    as_admin do
      completions = System::Managed.complete_for("name =")
      System::Managed.all.each do |h|
        assert completions.include?("name = #{h.name}"), "completion missing: #{h}"
      end
    end
  end

  test "can auto-complete searches by facts" do
    as_admin do
      completions = System::Managed.complete_for("facts.")
      FactName.order(:name).each do |fact|
        assert completions.include?(" facts.#{fact.name} "), "completion missing: #{fact}"
      end
    end
  end

  test "#rundeck returns hash" do
    h = systems(:one)
    rundeck = h.rundeck
    assert_kind_of Hash, rundeck
    assert_equal ['my5name.mydomain.net'], rundeck.keys
    assert_kind_of Hash, rundeck[h.name]
    assert_equal 'my5name.mydomain.net', rundeck[h.name]['systemname']
    assert_equal ['class=base'], rundeck[h.name]['tags']
  end

  test "#rundeck returns extra facts as tags" do
    h = systems(:one)
    h.params['rundeckfacts'] = "kernelversion, ipaddress\n"
    h.save!

    rundeck = h.rundeck
    assert rundeck[h.name]['tags'].include?('class=base'), 'puppet class missing'
    assert rundeck[h.name]['tags'].include?('kernelversion=2.6.9'), 'kernelversion fact missing'
    assert rundeck[h.name]['tags'].include?('ipaddress=10.0.19.33'), 'ipaddress fact missing'
  end

  test "should accept lookup_values_attributes" do
    h = systems(:redhat)
    as_admin do
      assert_difference "LookupValue.count" do
        assert h.update_attributes(:lookup_values_attributes => {"0" => {:lookup_key_id => lookup_keys(:one).id, :value => "8080" }})
      end
    end
  end

  test "can search systems by params" do
    parameter = parameters(:system)
    systems = System.search_for("params.system1 = system1")
    assert_equal systems.count, 1
    assert_equal systems.first.params['system1'], 'system1'
  end

  test "can search systems by inherited params from a system_group" do
    system = systems(:one)
    system.update_attribute(:system_group, system_groups(:inherited))
    GroupParameter.create( { :name => 'foo', :value => 'bar', :system_group => system.system_group.parent } )
    systems = System.search_for("params.foo = bar")
    assert_equal systems.count, 1
    assert_equal systems.first.params['foo'], 'bar'
  end

  test "should update puppet_proxy_id to the id of the validated proxy" do
    sp = smart_proxies(:puppetmaster)
    raw = parse_json_fixture('/facts_with_caps.json')
    System.importSystemAndFacts(raw['name'], raw['facts'], nil, sp.id)
    assert_equal sp.id, System.find_by_name('sinn1636.lan').puppet_proxy_id
  end

  test "shouldn't update puppet_proxy_id if it has been set" do
    System.new(:name => 'sinn1636.lan', :puppet_proxy_id => smart_proxies(:puppetmaster).id).save(:validate => false)
    sp = smart_proxies(:puppetmaster)
    raw = parse_json_fixture('/facts_with_certname.json')
    assert System.importSystemAndFacts(raw['name'], raw['facts'], nil, sp.id)
    assert_equal smart_proxies(:puppetmaster).id, System.find_by_name('sinn1636.lan').puppet_proxy_id
  end

  # Ip validations
  test "unmanaged systems don't require an IP" do
    h=System.new
    refute h.require_ip_validation?
  end

  test "CR's without IP attribute don't require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the CR
    h=System.new :managed => true,
      :compute_resource => compute_resources(:one),
      :compute_attributes => {:fake => "data"}
    refute h.require_ip_validation?
  end

  test "CR's with IP attribute do require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the CR
    h=System.new :managed => true,
      :compute_resource => compute_resources(:openstack),
      :compute_attributes => {:fake => "data"}
    assert h.require_ip_validation?
  end

  test "systems with a DNS-enabled Domain do require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the domain
    h=System.new :managed => true, :domain => domains(:mydomain)
    assert h.require_ip_validation?
  end

  test "systems without a DNS-enabled Domain don't require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the domain
    h=System.new :managed => true, :domain => domains(:useless)
    refute h.require_ip_validation?
  end

  test "systems with a DNS-enabled Subnet do require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the subnet
    h=System.new :managed => true, :subnet => subnets(:one)
    assert h.require_ip_validation?
  end

  test "systems without a DNS-enabled Subnet don't require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the subnet
    h=System.new :managed => true, :subnet => subnets(:four)
    refute h.require_ip_validation?
  end

  test "systems with a DHCP-enabled Subnet do require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the subnet
    h=System.new :managed => true, :subnet => subnets(:two)
    assert h.require_ip_validation?
  end

  test "systems without a DHCP-enabled Subnet don't require an IP" do
    Setting[:token_duration] = 30 #enable tokens so that we only test the subnet
    h=System.new :managed => true, :subnet => subnets(:four)
    refute h.require_ip_validation?
  end

  test "with tokens enabled systems don't require an IP" do
    Setting[:token_duration] = 30
    h=System.new :managed => true
    refute h.require_ip_validation?
  end

  test "with tokens disabled systems do require an IP" do
    h=System.new :managed => true
    assert h.require_ip_validation?
  end

  test "tokens disabled doesn't require an IP for image systems" do
    h=System.new :managed => true
    h.stubs(:capabilities).returns([:image])
    refute h.require_ip_validation?
  end

  private

  def parse_json_fixture(relative_path)
    return JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + relative_path)))
  end
end
