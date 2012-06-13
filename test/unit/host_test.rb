require 'test_helper'

class HostTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = User.find_by_login "admin"
  end

  test "should not save without a hostname" do
    host = Host.new
    assert !host.save
  end

  test "should fix mac address" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff"
    assert_equal "aa:bb:cc:dd:ee:ff", host.mac
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
    host = Host.create :name => "myhost.COMPANY.COM", :mac => "aabbccddeeff", :ip => "123.1.2.3",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "myhost.COMPANY.COM", host.name
  end

  test "should add hostname if it contains domain name" do
    host = Host.create :name => "myhost.company.com", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "myhost.company.com", host.name
  end

  test "should save hosts with full stop in their name" do
    host = Host.create :name => "my.host.company.com", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "my.host.company.com", host.name
  end


  test "should be able to save host" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.3",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :puppet_proxy => smart_proxies(:puppetmaster),
      :environment => environments(:production), :disk => "empty partition"
    assert host.valid?
    assert !host.new_record?
  end

  test "should import facts from yaml stream" do
    h=Host.new(:name => "sinn1636.lan")
    h.disk = "!" # workaround for now
    assert h.importFacts(YAML::load(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.yml"))))
  end

  test "should import facts from yaml of a new host" do
    assert Host.importHostAndFacts(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.yml")))
  end

  test "should not save if neither ptable or disk are defined when the host is managed" do
    if unattended?
      host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.4.4.03",
        :domain => domains(:mydomain), :operatingsystem => Operatingsystem.first, :subnet => subnets(:one),
        :architecture => Architecture.first, :environment => Environment.first, :managed => true
      assert !host.valid?
    end
  end

  test "should save if neither ptable or disk are defined when the host is not managed" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :managed => false
    assert host.valid?
  end

  test "should save if ptable is defined" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :puppet_proxy => smart_proxies(:puppetmaster),
      :subnet => subnets(:one), :architecture => architectures(:x86_64), :environment => environments(:production), :ptable => Ptable.first
    assert !host.new_record?
  end

  test "should save if disk is defined" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one),
      :architecture => architectures(:x86_64), :environment => environments(:production), :disk => "aaa", :puppet_proxy => smart_proxies(:puppetmaster)
    assert !host.new_record?
  end

  test "should not save if IP is not in the right subnet" do
    if unattended?
      host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
        :domain => domains(:mydomain), :operatingsystem => Operatingsystem.first, :subnet => subnets(:one), :managed => true,
        :architecture => Architecture.first, :environment => Environment.first, :ptable => Ptable.first, :puppet_proxy => smart_proxies(:puppetmaster)
      assert !host.valid?
    end
  end

  test "should import from external nodes output" do
    # create a dummy node
    Parameter.destroy_all
    host = Host.create :name => "myfullhost", :mac => "aabbacddeeff", :ip => "2.3.4.12",
      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one),
      :architecture => architectures(:x86_64), :environment => environments(:global_puppetmaster), :disk => "aaa",
      :puppet_proxy => smart_proxies(:puppetmaster)

    # dummy external node info
    nodeinfo = {"environment" => "global_puppetmaster",
      "parameters"=> {"puppetmaster"=>"puppet", "MYVAR"=>"value", "port" => "80",
        "ssl_port" => "443", "foreman_env"=> "global_puppetmaster", "owner_name"=>"Admin User",
        "root_pw"=>"xybxa6JUkz63w", "owner_email"=>"admin@someware.com"},
      "classes"=>["apache", "base"]}

    host.importNode nodeinfo

    assert_equal host.info, nodeinfo
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

  def setup_user_and_host
    @one            = users(:one)
    @one.hostgroups = []
    @one.domains    = []
    @one.user_facts = []
    @one.save!
    @host           = hosts(:one)
    @host.owner     = users(:two)
    @host.save!
    User.current    = @one
  end

  test "host cannot be edited without permission" do
    setup_user_and_host
    as_admin do
      @one.roles = [Role.find_by_name("Viewer")]
    end
    assert !@host.update_attributes(:name => "blahblahblah")
    assert_match /do not have permission/, @host.errors.full_messages.join("\n")
  end

  test "any host can be edited when permitted" do
    setup_user_and_host
    as_admin do
      @one.roles      = [Role.find_by_name("Edit hosts")]
    end
    assert @host.update_attributes(:name => "blahblahblah")
    assert_no_match /do not have permission/, @host.errors.full_messages.join("\n")
  end

  test "hosts can be edited when domains permit" do
    setup_user_and_host
    as_admin do
      @one.roles      = [Role.find_by_name("Edit hosts")]
      @one.domains    = [Domain.find_by_name("mydomain.net")]
    end
    assert @host.update_attributes(:name => "blahblahblah")
    assert_no_match /do not have permission/, @host.errors.full_messages.join("\n")
  end

  test "hosts cannot be edited when domains deny" do
    setup_user_and_host
    as_admin do
      @one.roles      = [Role.find_by_name("Edit hosts")]
      @one.domains    = [Domain.find_by_name("yourdomain.net")]
    end
    assert !@host.update_attributes(:name => "blahblahblah")
    assert_match /do not have permission/, @host.errors.full_messages.join("\n")
  end

  test "host cannot be created without permission" do
    setup_user_and_host
    as_admin do
      @one.roles = [Role.find_by_name("Viewer")]
    end
    host = Host.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "2.3.4.09",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production), :puppet_proxy => smart_proxies(:puppetmaster),
                       :subnet => subnets(:one), :disk => "empty partition")
    assert host.new_record?
    assert_match /do not have permission/, host.errors.full_messages.join("\n")
  end

  test "any host can be created when permitted" do
    setup_user_and_host
    as_admin do
      @one.roles = [Role.find_by_name("Create hosts")]
    end
    host = Host.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "2.3.4.11",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),  :puppet_proxy => smart_proxies(:puppetmaster),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :subnet => subnets(:one), :disk => "empty partition")
    assert !host.new_record?
    assert_no_match /do not have permission/, host.errors.full_messages.join("\n")
  end

  test "hosts can be created when hostgroups permit" do
    setup_user_and_host
    as_admin do
      @one.roles      = [Role.find_by_name("Create hosts")]
      @one.hostgroups = [Hostgroup.find_by_name("Common")]
    end
    host = Host.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "2.3.4.4",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :subnet => subnets(:one),
                       :disk => "empty partition", :hostgroup => hostgroups(:common))
    assert !host.new_record?
    assert_no_match /do not have permission/, host.errors.full_messages.join("\n")
  end

  test "hosts cannot be created when hostgroups deny" do
    setup_user_and_host
    as_admin do
      @one.roles      = [Role.find_by_name("Create hosts")]
      @one.hostgroups = [Hostgroup.find_by_name("Unusual")]
    end
    host = Host.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "2.3.4.9",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :subnet => subnets(:one),
                       :disk => "empty partition", :hostgroup => hostgroups(:common))
    assert host.new_record?
    assert_match /do not have permission/, host.errors.full_messages.join("\n")
  end

  test "host cannot be destroyed without permission" do
    setup_user_and_host
    as_admin do
      @one.roles = [Role.find_by_name("Viewer")]
    end
    assert !@host.destroy
    assert_match /do not have permission/, @host.errors.full_messages.join("\n")
  end

  test "any host can be destroyed when permitted" do
    setup_user_and_host
    as_admin do
      @one.roles = [Role.find_by_name("Destroy hosts")]
    end
    assert @host.destroy
    assert_no_match /do not have permission/, @host.errors.full_messages.join("\n")
  end

  test "hosts can be destroyed when ownership permits" do
    setup_user_and_host
    as_admin do
      @one.roles = [Role.find_by_name("Destroy hosts")]
      @host.update_attribute :owner,  users(:one)
    end
    assert @host.destroy
    assert_no_match /do not have permission/, @host.errors.full_messages.join("\n")
  end

  test "hosts cannot be destroyed when ownership denies" do
    setup_user_and_host
    as_admin do
      @one.roles   = [Role.find_by_name("Destroy hosts")]
      @one.domains = [domains(:yourdomain)] # This does not grant access but does ensure that access is constrained
      @host.owner  = users(:two)
      @host.save!
    end
    assert !@host.destroy
    assert_match /do not have permission/, @host.errors.full_messages.join("\n")
  end

  test "a fqdn Host should be assigned to a domain if such domain exists" do
    domain = domains(:mydomain)
    host = Host.create :name => "host.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one),
      :architecture => architectures(:x86_64), :environment => environments(:production), :disk => "aaa"
    host.valid?
    assert_equal domain, host.domain
  end

  test "a system should retrieve its gPXE template if it is associated to the correct env and host group" do
    host = Host.create :name => "host.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => Operatingsystem.find_by_name("centos"), :subnet => subnets(:one), :hostgroup => Hostgroup.find_by_name("common"),
      :architecture => Architecture.first, :environment => Environment.find_by_name("production"), :disk => "aaa"

    assert_equal ConfigTemplate.find_by_name("MyString"), host.configTemplate({:kind => "gPXE"})
  end

  test "a system should retrieve its provision template if it is associated to the correct host group only" do
    host = Host.create :name => "host.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => Operatingsystem.find_by_name("centos"), :subnet => subnets(:one), :hostgroup => Hostgroup.find_by_name("common"),
      :architecture => Architecture.first, :environment => Environment.find_by_name("production"), :disk => "aaa"

    assert_equal ConfigTemplate.find_by_name("MyString2"), host.configTemplate({:kind => "provision"})
  end

  test "a system should retrieve its script template if it is associated to the correct OS only" do
    host = Host.create :name => "host.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => Operatingsystem.find_by_name("centos"), :subnet => subnets(:one), :hostgroup => Hostgroup.find_by_name("common"),
      :architecture => Architecture.first, :environment => Environment.find_by_name("production"), :disk => "aaa"

    assert_equal ConfigTemplate.find_by_name("MyScript"), host.configTemplate({:kind => "script"})
  end

 test "a system should retrieve its finish template if it is associated to the correct environment only" do
    host = Host.create :name => "host.mydomain.net", :mac => "aabbccddeaff", :ip => "2.3.04.03",
      :operatingsystem => Operatingsystem.find_by_name("centos"), :subnet => subnets(:one), :hostgroup => Hostgroup.find_by_name("common"),
      :architecture => Architecture.first, :environment => Environment.find_by_name("production"), :disk => "aaa"

    assert_equal ConfigTemplate.find_by_name("MyFinish"), host.configTemplate({:kind => "finish"})
  end

 test "when provisioning a new host we should not call puppetca if its disabled" do
   # TODO improve this test :-)
   Setting[:manage_puppetca] = false
   assert hosts(:one).handle_ca
 end

 test "custom_disk_partition_with_erb" do
   h = hosts(:one)
   h.disk = "<%= 1 + 1 %>"
   h.save

   assert_equal "2", h.diskLayout
 end

  test "models are updated when host.model has no value" do
    h = hosts(:one)
    as_admin do
      FactValue.create!(:value => "superbox", :host_id => h.id, :fact_name_id => 1)
    end
    assert_difference('Model.count') do
    facts = YAML::load(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.yml")))
      h.populateFieldsFromFacts facts.values
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

  test "hostgroup should set default vm values when none exists" do
    hg = hostgroups(:db)
    assert_not_nil hg.memory
    h = Host.new
    h.hostgroup = hg
    assert !h.valid?
    assert_equal hg.memory, h.memory
  end

  test "host os attributes must be associated with the host os" do
    h = hosts(:redhat)
    h.managed = true
    h.architecture = architectures(:sparc)
    assert !h.os.architectures.include?(h.arch)
    assert !h.valid?
    assert_equal ["#{h.architecture} does not belong to #{h.os} operating system"], h.errors[:architecture_id]
  end

  test "host puppet classes must belong to the host environment" do
    h = hosts(:redhat)

    pc = puppetclasses(:two)
    h.puppetclasses << pc
    assert !h.environment.puppetclasses.include?(pc)
    assert !h.valid?
    assert_equal ["#{pc} does not belong to the #{h.environment} environment"], h.errors[:puppetclasses]
  end

  test "when changing host environment, its puppet classes should be verified" do
    h = hosts(:one)
    pc = puppetclasses(:one)
    h.puppetclasses << pc
    assert h.save
    h.environment = environments(:testing)
    assert !h.save
    assert_equal ["#{pc} does not belong to the #{h.environment} environment"], h.errors[:puppetclasses]
  end

  test "name should be lowercase" do
    h = hosts(:redhat)
    assert h.valid?
    h.name.upcase!
    assert !h.valid?
  end

  test "should allow to save root pw" do
    h = hosts(:redhat)
    pw = h.root_pass
    h.root_pass = "token"
    assert h.save
    assert_not_equal pw, h.root_pass
  end

  test "should allow to revert to default root pw" do
    h = hosts(:redhat)
    h.root_pass = "token"
    assert h.save
    h.root_pass = ""
    assert h.save
    assert_equal h.root_pass, Setting.root_pass
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

end
