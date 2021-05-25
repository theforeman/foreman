require 'test_helper'

class OperatingsystemTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test "shouldn't save with blank attributes" do
    operating_system = Operatingsystem.new
    assert !operating_system.save
  end

  should validate_presence_of(:name)

  should allow_value(*valid_name_list).for(:name)
  should_not allow_value(*invalid_name_list).for(:name)

  should allow_value('11111').for(:major)
  should allow_value(11111).for(:major)

  should allow_value('11111').for(:minor)
  should allow_value(11111).for(:minor)

  should allow_values('Base64', 'SHA256', 'SHA512').for(:password_hash)
  should_not allow_value('INVALID_HASH').for(:password_hash)

  should validate_length_of(:description).is_at_most(255)
  should allow_value(*valid_name_list).for(:description)

  test "name and major should be unique" do
    operating_system = FactoryBot.build(:operatingsystem, :name => "Ubuntu", :major => "10", :release_name => "rn10")
    assert operating_system.save
    other_operating_system = FactoryBot.build(:operatingsystem, :name => "Ubuntu", :major => "10", :release_name => "rn10")
    refute_valid other_operating_system
  end

  test "should not destroy while using" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "10", :release_name => "rn10"
    assert operating_system.save

    host = FactoryBot.create(:host)
    host.operatingsystem = operating_system
    host.save(:validate => false)

    assert !operating_system.destroy
  end

  # Methods tests
  test "to_label should print correctly" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "10", :release_name => "rn9"
    assert operating_system.to_label == "Ubuntu 9.10"
  end

  test "to_s retrives label" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "10", :release_name => "rn9"
    assert operating_system.to_s == operating_system.to_label
  end

  test "should find by fullname string" do
    str = "Redhat 6.1"
    os = Operatingsystem.find_by_to_label(str)
    assert_equal str, os.fullname
  end

  test "should find by fullname if description does not exist" do
    str = "centos 5.3"
    os = Operatingsystem.find_by_to_label(str)
    assert_equal str, os.to_label
  end

  test "should set description by setting to_label" do
    os = operatingsystems(:centos5_3)
    os.update(:to_label => "CENTOS 5.3")
    assert_equal os.description, os.to_label
  end

  test "should have unique description if not blank to be valid" do
    os = operatingsystems(:centos5_3)
    assert os.valid?
    os.description = "RHEL 6.1"
    refute os.valid?
    assert os.errors[:description].include?("has already been taken")
  end

  test "should return os label (description or fullname) for method operatingsystem_names" do
    medium = media(:one)
    assert_equal 2, medium.operatingsystem_ids.count
    assert_equal 2, medium.operatingsystem_names.count
    assert_equal ["RHEL 6.1", "centos 5.3"], medium.operatingsystem_names.sort
  end

  test "should add os association by passing os labels (description or fullname) of operatingsystems" do
    medium = media(:one)
    medium.operatingsystem_names = ["centos 5.3", "RHEL 6.1", "Ubuntu 10.10"]
    assert_equal 3, medium.operatingsystem_ids.count
    assert_equal 3, medium.operatingsystem_names.count
    assert_equal ["RHEL 6.1", "Ubuntu 10.10", "centos 5.3"], medium.operatingsystem_names.sort
  end

  test "should add os association by passing os fullname even if description exists" do
    medium = media(:one)
    # pass Redhat 6.1 rather than RHEL 6.1
    medium.operatingsystem_names = ["centos 5.3", "Redhat 6.1", "Ubuntu 10.10"]
    assert_equal 3, medium.operatingsystem_ids.count
    assert_equal 3, medium.operatingsystem_names.count
    assert_equal ["RHEL 6.1", "Ubuntu 10.10", "centos 5.3"], medium.operatingsystem_names.sort
  end

  test "should delete os associations by passing os labels (description or fullname) of operatingsystems" do
    medium = media(:one)
    medium.operatingsystem_names = ["centos 5.3"]
    assert_equal 1, medium.operatingsystem_ids.count
    assert_equal 1, medium.operatingsystem_names.count
    assert_equal ["centos 5.3"], medium.operatingsystem_names
  end

  describe "families" do
    let(:os) { Operatingsystem.new :name => "dummy", :major => 7 }

    test "os family can be one of defined os families" do
      Operatingsystem.families.each do |family|
        os.release_name = "nicereleasename" if (family == 'Debian')
        os.family = family
        assert_valid os
      end
    end

    test "os family can't be anything else than defined os families" do
      os.family = "unknown"
      assert !os.valid?
    end

    test "os family can be nil" do
      os.family = nil
      assert os.valid?
    end

    test "setting os family to a blank string is valid" do
      os.family = ""
      assert os.valid?
    end

    test "blank os family is saved as nil" do
      os.family = ""
      assert_nil os.family
    end

    test "deduce_family correctly returns the family when not set" do
      os.name = 'Redhat'
      refute os.family
      assert_equal 'Redhat', os.deduce_family
    end

    test "set_family correctly sets the family" do
      os.name = 'Redhat'
      os.save
      assert_equal 'Redhat', os.reload.family
    end

    test "families_as_collection contains correct names and values" do
      families = Operatingsystem.families_as_collection
      assert_equal ["AIX", "Altlinux", "Arch Linux", "CoreOS", "Debian", "Fedora CoreOS", "FreeBSD", "Gentoo", "Junos", "NX-OS", 'RancherOS', "Red Hat", "Red Hat CoreOS", "SUSE", "Solaris", "VRP", "Windows", "XenServer"], families.map(&:name).sort
      assert_equal ["AIX", "Altlinux", "Archlinux", "Coreos", "Debian", "Fcos", "Freebsd", "Gentoo", "Junos", "NXOS", 'Rancheros', "Redhat", "Rhcos", "Solaris", "Suse", "VRP", "Windows", "Xenserver"], families.map(&:value).sort
    end
  end

  describe "descriptions" do
    test "Redhat LSB description should be correctly shortened" do
      assert_equal 'RHEL 6.4', Redhat.new.shorten_description("Red Hat Enterprise Linux release 6.4 (Santiago)")
    end

    test "Fedora LSB description should be correctly shortened" do
      assert_equal 'Fedora 19', Redhat.new.shorten_description("Fedora release 19 (Schrodinger's Cat)")
    end

    test "Debian LSB description should be correctly shortened" do
      assert_equal 'Debian 7.1', Debian.new.shorten_description("Debian GNU/Linux 7.1 (wheezy)")
    end

    test "Ubuntu LSB is unaltered" do
      assert_equal 'Ubuntu 12.04.3 LTS', Debian.new.shorten_description("Ubuntu 12.04.3 LTS")
    end

    test "SLES LSB description should be correctly shortened" do
      assert_equal 'SLES 11', Suse.new.shorten_description("SUSE Linux Enterprise Server 11 (x86_64)")
    end

    test "openSUSE LSB description should be correctly shortened" do
      assert_equal 'openSUSE 11.4', Suse.new.shorten_description("openSUSE 11.4 (x86_64)")
    end

    test "OSes without a shorten_description method fall back to description" do
      assert_equal 'Arch Linux', Archlinux.new.shorten_description("Arch Linux")
    end
  end

  test "release name is changed to lower case on save" do
    os = FactoryBot.build(:operatingsystem, release_name: 'TEST')
    os.save!
    assert_equal 'test', os.release_name
  end

  test "should find os name using free text search only" do
    operatingsystems = Operatingsystem.search_for('centos')
    assert_equal 1, operatingsystems.count
    assert_equal operatingsystems(:centos5_3), operatingsystems.first
  end

  test "should create os with two different parameters" do
    pid = Time.now.to_i
    operatingsystem = FactoryBot.build_stubbed(:operatingsystem, :os_parameters_attributes =>
        {pid += 1 => {"name" => "a", "value" => "1"},
         pid +  1 => {"name" => "b", "value" => "1"}})
    assert_valid operatingsystem
  end

  test "should not create os with two new parameters with the same name" do
    pid = Time.now.to_i
    operatingsystem = FactoryBot.build_stubbed(:operatingsystem, :os_parameters_attributes =>
        {pid += 1 => {"name" => "a", "value" => "1"},
         pid += 1 => {"name" => "a", "value" => "2"},
         pid +  1 => {"name" => "b", "value" => "1"}})
    refute_valid operatingsystem
    assert_equal "has already been taken", operatingsystem.os_parameters.select { |param| param.name == 'a' }.sort[1].errors[:name].first
    assert_equal "Please ensure the following parameters name are unique", operatingsystem.errors[:os_parameters].first
  end

  test "should not create os with a new parameter with the same name as a existing parameter" do
    operatingsystem = FactoryBot.create(:operatingsystem)
    operatingsystem.os_parameters = [OsParameter.new({:name => "a", :value => "3"})]
    assert operatingsystem.valid?
    operatingsystem.os_parameters.push(OsParameter.new({:name => "a", :value => "43"}))
    refute_valid operatingsystem
  end

  test "should not create os with an invalid parameter - no name" do
    pid = Time.now.to_i
    operatingsystem = FactoryBot.build_stubbed(:operatingsystem, :os_parameters_attributes =>
        {pid += 1 => {"value" => "1"},
         pid += 1 => {"name" => "a", "value" => "2"},
         pid +  1 => {"name" => "b", "value" => "1"}})
    refute_valid operatingsystem
  end

  test "provides available loaders" do
    assert Operatingsystem.new.available_loaders.include? "None"
    assert Operatingsystem.new.available_loaders.include? "PXELinux BIOS"
  end

  test "provides available loaders for Redhat" do
    assert Redhat.new.available_loaders.include? "PXELinux BIOS"
    assert Redhat.new.available_loaders.include? "Grub UEFI"
    assert Redhat.new.available_loaders.include? "Grub2 UEFI"
  end

  test "provides available loaders for Solaris" do
    assert Solaris.new.available_loaders.include? "None"
  end

  test "should not have preferred pxe loader for an OS without architecture associated" do
    assert_nil Operatingsystem.new.preferred_loader
  end

  test "should have preferred pxe loader for an Solaris OS without any templates" do
    assert_nil Solaris.new.preferred_loader
  end

  test "should have preferred pxe loader for OS with PXELinux template" do
    os = FactoryBot.create(:operatingsystem, :with_associations, :with_pxelinux)
    assert_equal "PXELinux BIOS", os.preferred_loader
  end

  test "should have preferred pxe loader for OS with Grub template" do
    os = FactoryBot.create(:operatingsystem, :with_associations, :with_grub)
    assert_equal "Grub UEFI", os.preferred_loader
  end

  test "additional_media returns media from medium provider" do
    os = FactoryBot.create(:operatingsystem, :with_associations, :with_pxelinux)
    additional_media = [{name: 'EPEL', url: 'http://yum.example.com/epel'}]
    MediumProviders::Default.any_instance.stubs(:additional_media).returns(additional_media)
    provider = MediumProviders::Default.new(FactoryBot.build(:host))

    os_media = os.additional_media(provider)
    assert_instance_of HashWithIndifferentAccess, os_media.first
    assert_equal os_media, additional_media.map(&:with_indifferent_access)
  end

  context 'os default templates' do
    setup do
      @template_kind = FactoryBot.create(:template_kind)
      @provisioning_template = FactoryBot.create(:provisioning_template, :template_kind_id => @template_kind.id)
      @os = operatingsystems(:centos5_3)
      @os.update(:os_default_templates_attributes =>
                               [{ :provisioning_template_id => @provisioning_template.id, :template_kind_id => @template_kind.id }]
                )
    end

    test 'should create os default templates' do
      assert_valid @os
      assert_equal(@os.os_default_templates.last.template_kind_id, @template_kind.id)
      assert_equal(@os.os_default_templates.last.provisioning_template_id, @provisioning_template.id)
    end

    test 'should remove os default template' do
      # Association deleted, yet template_kind and provisioning_template not.
      assert_difference('@os.os_default_templates.length', -1) do
        @os.update(:os_default_templates_attributes => { :id => @os.os_default_templates.last.id, :_destroy => 1 })
      end
      assert_valid @template_kind
      assert_valid @provisioning_template
    end
  end

  test 'name can include utf-8 and non-alpha numeric chars' do
    operatingsystem = FactoryBot.build_stubbed(:operatingsystem, :name => '<applet>מערכתההפעלהשלי', :major => 4)
    assert operatingsystem.valid?
    assert_equal("#{operatingsystem.id}-applet-מערכתההפעלהשלי 4", operatingsystem.to_param)
  end

  context 'name should be unique in scope of major and minor' do
    setup do
      @os = FactoryBot.create(:operatingsystem, :name => 'centos', :major => 8, :minor => 3)
    end

    test 'should not create os with existing name, major and minor' do
      operatingsystem = Operatingsystem.new(:name => "centos", :major => '8', :minor => '3')
      assert_equal(@os.name, operatingsystem.name)
      assert_equal(@os.major, operatingsystem.major)
      assert_equal(@os.minor, operatingsystem.minor)
      refute operatingsystem.valid?
      refute operatingsystem.save
    end

    test 'should create os with existing name, major and different minor' do
      operatingsystem = Operatingsystem.new(:name => "centos", :major => '8', :minor => '9')
      assert_equal(@os.name, operatingsystem.name)
      assert_equal(@os.major, operatingsystem.major)
      refute_equal(@os.minor, operatingsystem.minor)
      assert operatingsystem.valid?
      assert operatingsystem.save
    end

    test 'should create os with existing name, minor and different major' do
      operatingsystem = Operatingsystem.new(:name => "centos", :major => '7', :minor => '3')
      assert_equal(@os.name, operatingsystem.name)
      assert_equal(@os.minor, operatingsystem.minor)
      refute_equal(@os.major, operatingsystem.major)
      assert operatingsystem.valid?
      assert operatingsystem.save
    end
  end

  describe '#boot_filename' do
    test 'should be the ipxe unattended url for iPXE' do
      host = FactoryBot.build(:host, :managed, pxe_loader: 'iPXE Embedded')
      assert_equal 'http://foreman.some.host.fqdn/unattended/iPXE', host.operatingsystem.boot_filename(host)
    end

    test 'should be the smart proxy ipxe unattended url for iPXE' do
      host = FactoryBot.build(:host, :managed, :with_tftp_and_httpboot_subnet, pxe_loader: 'iPXE Embedded')
      assert_equal 'http://foreman.some.host.fqdn/unattended/iPXE', host.operatingsystem.boot_filename(host)
    end

    test 'should be the smart proxy and httpboot port for UEFI HTTP' do
      SmartProxy.any_instance.expects(:setting).with(:HTTPBoot, 'http_port').returns(1234)
      host = FactoryBot.build(:host, :managed, :with_tftp_and_httpboot_subnet, pxe_loader: 'Grub2 UEFI HTTP')
      assert_match(%r{http://somewhere.*net:1234/httpboot/grub2/grubx64.efi}, host.operatingsystem.boot_filename(host))
    end

    test 'should be the smart proxy and httpboot port for UEFI HTTPS' do
      SmartProxy.any_instance.expects(:setting).with(:HTTPBoot, 'https_port').returns(1235)
      host = FactoryBot.build(:host, :managed, :with_tftp_and_httpboot_subnet, pxe_loader: 'Grub2 UEFI HTTPS')
      assert_match(%r{https://somewhere.*net:1235/httpboot/grub2/grubx64.efi}, host.operatingsystem.boot_filename(host))
    end

    test 'should not raise an error without httpboot feature for PXE' do
      host = FactoryBot.build(:host, :managed, :with_tftp_and_httpboot_subnet, pxe_loader: 'PXELinux BIOS')
      host.subnet.expects(:httpboot?).returns(false)
      assert_equal "pxelinux.0", host.operatingsystem.boot_filename(host)
    end

    test 'should not raise an error with httpboot without port for PXE' do
      host = FactoryBot.build(:host, :managed, :with_tftp_and_httpboot_subnet, pxe_loader: 'PXELinux BIOS')
      host.subnet.expects(:httpboot?).returns(true)
      SmartProxy.any_instance.stubs(:httpboot_http_port).returns(nil)
      SmartProxy.any_instance.stubs(:httpboot_https_port).returns(nil)
      assert_equal "pxelinux.0", host.operatingsystem.boot_filename(host)
    end

    test 'should raise an error without subnet' do
      host = FactoryBot.build(:host, :managed, pxe_loader: 'Grub2 UEFI HTTP')
      assert_raises Foreman::Exception do
        host.operatingsystem.boot_filename(host)
      end
    end

    test 'should raise an error without httpboot feature' do
      host = FactoryBot.build(:host, :managed, :with_tftp_and_httpboot_subnet, pxe_loader: 'Grub2 UEFI HTTP')
      host.subnet.expects(:httpboot?).returns(false)
      assert_raises Foreman::Exception do
        host.operatingsystem.boot_filename(host)
      end
    end

    test 'should raise an error without httpboot port' do
      host = FactoryBot.build(:host, :managed, :with_tftp_and_httpboot_subnet, pxe_loader: 'Grub2 UEFI HTTP')
      host.subnet.expects(:httpboot?).returns(true)
      SmartProxy.any_instance.stubs(:httpboot_http_port).returns(nil)
      assert_raises Foreman::Exception do
        host.operatingsystem.boot_filename(host)
      end
    end
  end

  test "can search os with tilde operator when value is other than plain text" do
    os = FactoryBot.create(:operatingsystem)
    os.os_parameters << OsParameter.create(
      :name => "os_yaml", :value => "---\ncentos 7.0: use it for 7.0\ncentos 8.0: use it for 8.0\n", :parameter_type => 'yaml'
    )
    parameter = os.os_parameters.first
    results = Operatingsystem.search_for(%{params.#{parameter.name} ~ "centos"})
    assert results.include?(os)
  end

  test "can't search os with equal operator when value is other than plain text" do
    os = FactoryBot.create(:operatingsystem)
    os.os_parameters << OsParameter.create(
      :name => "os_arr", :value => "['centos 7.0','centos 8.0']", :parameter_type => 'array'
    )
    parameter = os.os_parameters.first
    results = Operatingsystem.search_for(%{params.#{parameter.name} = "#{parameter.searchable_value}"})
    refute results.include?(os)
  end

  test "should assign 'host initial configuration' template after create" do
    os = FactoryBot.create(:operatingsystem)
    assert_equal Setting[:default_host_init_config_template], os.provisioning_templates[0]&.name
  end

  context 'has_default_template?' do
    setup do
      @kind = TemplateKind.find_by(name: 'host_init_config')
    end
    test 'with template' do
      os = FactoryBot.create(:operatingsystem)

      assert_not_empty os.os_default_templates
      assert os.has_default_template?(@kind)
    end

    test 'without template' do
      os = FactoryBot.create(:operatingsystem)
      os.os_default_templates = []

      assert_empty os.os_default_templates
      refute os.has_default_template?(@kind)
    end
  end
end
