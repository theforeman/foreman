require 'test_helper'

class OperatingsystemTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
    Operatingsystem.all.each do |o| #because we load from fixtures, counters aren't updated
      Operatingsystem.reset_counters(o.id,:hosts)
      Operatingsystem.reset_counters(o.id,:hostgroups)
    end
  end

  test "shouldn't save with blank attributes" do
    operating_system = Operatingsystem.new
    assert !operating_system.save
  end

  test "name shouldn't be blank" do
    operating_system = Operatingsystem.new :name => "   ", :major => "9"
    assert operating_system.name.strip.empty?
    assert !operating_system.save
  end

  test "name shouldn't contain white spaces" do
    operating_system = Operatingsystem.new :name => " U bun     tu ", :major => "9"
    assert !operating_system.name.squeeze(" ").tr(' ', '').empty?
    assert !operating_system.save

    operating_system.name.squeeze!(" ").tr!(' ', '')
    assert !operating_system.name.include?(' ')
    assert operating_system.save
  end

  test "major should be numeric" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9"
    assert operating_system.major.to_i != 0 if operating_system.major != "0"
    assert operating_system.save

    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "nine"
    assert !operating_system.major.to_i != 0 if operating_system.major != "0"
    assert !operating_system.save
  end

  test "minor should be numeric" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "1"
    assert operating_system.minor.to_i != 0 if operating_system.minor != "0"
    assert operating_system.save

    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "one"
    assert !operating_system.minor.to_i != 0 if operating_system.minor != "0"
    assert !operating_system.save
  end

  #TODO: this test should be uncommented after validation is implemented
  # test "name and major should be unique" do
  #   operating_system = Operatingsystem.new :name => "Ubuntu", :major => "10"
  #   assert operating_system.save

  #   other_operating_system = Operatingsystem.new :name => "Ubuntu", :major => "10"
  #   assert !other_operating_system.save
  # end

  test "should not destroy while using" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "10"
    assert operating_system.save

    host = hosts(:one)
    host.os = operating_system
    host.save(:validate => false)

    assert !operating_system.destroy
  end

  # Methods tests
  test "to_label should print correctly" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "10"
    assert operating_system.to_label == "Ubuntu 9.10"
  end

  test "to_s retrives label" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "10"
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
    os.update_attributes(:to_label => "CENTOS 5.3")
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
      os.family = Operatingsystem.families[0]
      assert os.valid?
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
      assert_equal nil, os.family
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
      assert_equal ["AIX", "Altlinux", "Arch Linux", "Debian", "FreeBSD", "Gentoo", "Junos", "Red Hat", "SUSE", "Solaris", "Windows"], families.map(&:name).sort
      assert_equal ["AIX", "Altlinux", "Archlinux", "Debian", "Freebsd", "Gentoo", "Junos", "Redhat", "Solaris", "Suse", "Windows"], families.map(&:value).sort
    end
  end

  describe "descriptions" do
    test "Redhat LSB description should be correctly shortened" do
      assert_equal 'RHEL 6.4', Redhat.shorten_description("Red Hat Enterprise Linux release 6.4 (Santiago)")
    end

    test "Fedora LSB description should be correctly shortened" do
      assert_equal 'Fedora 19', Redhat.shorten_description("Fedora release 19 (Schrodinger's Cat)")
    end

    test "Debian LSB description should be correctly shortened" do
      assert_equal 'Debian 7.1', Debian.shorten_description("Debian GNU/Linux 7.1 (wheezy)")
    end

    test "Ubuntu LSB is unaltered" do
      assert_equal 'Ubuntu 12.04.3 LTS', Debian.shorten_description("Ubuntu 12.04.3 LTS")
    end

    test "SLES LSB description should be correctly shortened" do
      assert_equal 'SLES 11', Suse.shorten_description("SUSE Linux Enterprise Server 11 (x86_64)")
    end

    test "openSUSE LSB description should be correctly shortened" do
      assert_equal 'openSUSE 11.4', Suse.shorten_description("openSUSE 11.4 (x86_64)")
    end

    test "OSes without a shorten_description method fall back to description" do
      assert_equal 'Arch Linux', Archlinux.shorten_description("Arch Linux")
    end
  end

  test "should update hosts_count" do
    os = operatingsystems(:ubuntu1010)
    assert_difference "os.hosts_count" do
      hosts(:one).update_attribute(:operatingsystem, os)
      os.reload
    end
  end

  test "should update hostgroups_count" do
    os = operatingsystems(:ubuntu1010)
    assert_difference "os.hostgroups_count" do
      hostgroups(:common).update_attribute(:operatingsystem, os)
      os.reload
    end
  end

  test "should find os name using free text search only" do
    operatingsystems = Operatingsystem.search_for('OpenSuse')
    assert_equal 1, operatingsystems.count
    assert_equal operatingsystems(:suse), operatingsystems.first
  end

  test "should create os with a name of 255 characters" do
    os = FactoryGirl.build(:operatingsystem, :name => 'a' * 255)
    assert_valid os
    assert os.save
  end

  test "should not create os with a name of 256 characters" do
    os = FactoryGirl.build(:operatingsystem, :name => 'a' * 256)
    refute_valid os
    assert_equal "is too long (maximum is 255 characters)", os.errors[:name].first
  end

  test "should create os with a major version of 5 characters" do
    os = FactoryGirl.build(:operatingsystem, :major => '1' * 5)
    assert_valid os
  end

  test "should not create os with a major of 6 characters" do
    os = FactoryGirl.build(:operatingsystem, :major => '1' * 6)
    refute_valid os
    assert_equal "is too long (maximum is 5 characters)", os.errors[:major].first
  end

  test "should not create os with a negative major" do
    os = FactoryGirl.build(:operatingsystem, :major => -33)
    refute_valid os
    assert_equal "must be greater than or equal to 0", os.errors[:major].first
  end

  test "should create os with a minor version of 16 characters" do
    os = FactoryGirl.build(:operatingsystem, :minor => '1' * 16)
    assert_valid os
  end

  test "should not create os with a minor of 17 characters" do
    os = FactoryGirl.build(:operatingsystem, :minor => '1' * 17)
    refute_valid os
    assert_equal "is too long (maximum is 16 characters)", os.errors[:minor].first
  end

  test "should not create os with a negative minor" do
    os = FactoryGirl.build(:operatingsystem, :minor => -50)
    refute_valid os
    assert_equal "must be greater than or equal to 0", os.errors[:minor].first
  end

end
