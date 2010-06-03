require 'test_helper'

class HostTest < ActiveSupport::TestCase
  setup do
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

  test "should add hostname if it contains domain name" do
    host = Host.create :name => "myhost.company.com", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "myhost.company.com", host.name
  end

  test "should safe hosts with full stop in their name" do
    host = Host.create :name => "my.host.company.com", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "my.host.company.com", host.name
  end


  test "should be able to save host" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"
    if host.new_record?
      puts host.errors.full_messages
    end
    assert host.valid?
    assert !host.new_record?
  end

  test "should import facts from yaml stream" do
    h=Host.new(:name => "sinn1636.lan")
    h.disk = "!" # workaround for now
    assert true == h.importFacts(YAML::load(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.yml"))))
  end

  test "should import facts from yaml of a new host" do
    assert Host.importHostAndFacts(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.yml")))
  end
  if SETTINGS[:unattended].nil? or SETTINGS[:unattended]
      test "should not save if neither ptable or disk are defined when the host is managed" do
        host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
          :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
          :architecture => Architecture.first, :environment => Environment.first, :managed => true
        assert !host.valid?
      end

      test "should save if neither ptable or disk are defined when the host is not managed" do
        host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
          :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
          :architecture => Architecture.first, :environment => Environment.first, :managed => false
        assert host.valid?
      end
  end

  test "should save if ptable is defined" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :ptable => Ptable.first
    assert !host.new_record?
  end

  test "should save if disk is defined" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "aaa"
    assert !host.new_record?
  end

  test "should import from external nodes output" do
    # create a dummy node
    Parameter.destroy_all
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "aaa"

    # dummy external node info
    nodeinfo = {"environment" => "global_puppetmaster", "parameters"=>{"puppetmaster"=>"puppet", "MYVAR"=>"value"}, "classes"=>["apache", "base"]}

    host.importNode nodeinfo

    assert host.info == nodeinfo
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
    assert @host.update_attributes :name => "blahblahblah"
    assert_no_match /do not have permission/, @host.errors.full_messages.join("\n")
  end

  test "hosts can be edited when domains permit" do
    setup_user_and_host
    as_admin do
      @one.roles      = [Role.find_by_name("Edit hosts")]
      @one.domains    = [Domain.find_by_name("mydomain.net")]
    end
    assert @host.update_attributes :name => "blahblahblah"
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
    host = Host.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "123.05.02.09",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :disk => "empty partition")
    assert host.new_record?
    assert_match /do not have permission/, host.errors.full_messages.join("\n")
  end

  test "any host can be created when permitted" do
    setup_user_and_host
    as_admin do
      @one.roles = [Role.find_by_name("Create hosts")]
    end
    host = Host.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "123.05.02.09",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :disk => "empty partition")
    assert !host.new_record?
    assert_no_match /do not have permission/, host.errors.full_messages.join("\n")
  end

  test "hosts can be created when hostgroups permit" do
    setup_user_and_host
    as_admin do
      @one.roles      = [Role.find_by_name("Create hosts")]
      @one.hostgroups = [Hostgroup.find_by_name("Common")]
    end
    host = Host.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "123.05.02.09",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :disk => "empty partition", :hostgroup => Hostgroup.find_by_name("Common"))
    assert !host.new_record?
    assert_no_match /do not have permission/, host.errors.full_messages.join("\n")
  end

  test "hosts cannot be created when hostgroups deny" do
    setup_user_and_host
    as_admin do
      @one.roles      = [Role.find_by_name("Create hosts")]
      @one.hostgroups = [Hostgroup.find_by_name("Unusual")]
    end
    host = Host.create(:name => "blahblah", :mac => "aabbecddee19", :ip => "123.05.02.09",
                       :domain => domains(:mydomain),  :operatingsystem => operatingsystems(:centos5_3),
                       :architecture => architectures(:x86_64), :environment => environments(:production),
                       :disk => "empty partition", :hostgroup => Hostgroup.find_by_name("Common"))
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
    domain = Domain.find_or_create_by_name "company.com"
    host = Host.create :name => "host.company.com", :mac => "aabbccddeaff", :ip => "123.2.02.03",
      :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "aaa"
    assert host.save
    assert_equal domain, host.domain
  end

end
