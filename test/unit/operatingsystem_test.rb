require 'test_helper'

class OperatingsystemTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
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

  def setup_user operation
    super operation, "operatingsystems"
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Operatingsystem.create :name => "dummy", :major => 7
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Operatingsystem.create :name => "dummy", :major => 7
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Operatingsystem.first
    as_admin do
      record.hosts.delete_all
      record.hostgroups.delete_all
      assert record.destroy
    end
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Operatingsystem.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Operatingsystem.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Operatingsystem.first
    record.name = "renamed"
    as_admin do
      record.hosts.destroy_all
    end
    assert !record.save
    assert record.valid?
  end

  test "should find by fullname string" do
    str = "Redhat 6.1"
    os = Operatingsystem.find_by_fullname(str)
    assert_equal str, os.fullname
  end

  test "should return os fullnames for method operatingsystem_names" do
    medium = media(:one)
    assert_equal 2, medium.operatingsystem_ids.count
    assert_equal 2, medium.operatingsystem_names.count
    assert_equal ["Redhat 6.1", "centos 5.3"], medium.operatingsystem_names.sort
  end

  test "should add os association by passing fullnames of operatingsystems" do
    medium = media(:one)
    medium.operatingsystem_names = ["centos 5.3", "Redhat 6.1", "Ubuntu 10.10"]
    assert_equal 3, medium.operatingsystem_ids.count
    assert_equal 3, medium.operatingsystem_names.count
    assert_equal ["Redhat 6.1", "Ubuntu 10.10", "centos 5.3"], medium.operatingsystem_names.sort
  end

  test "should delete os associations by passing fullnames of operatingsystems" do
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
      assert_equal ["AIX", "Arch Linux", "Debian", "FreeBSD", "Gentoo", "Junos", "Red Hat", "SUSE", "Solaris", "Windows"], families.map(&:name).sort
      assert_equal ["AIX", "Archlinux", "Debian", "Freebsd", "Gentoo", "Junos", "Redhat", "Solaris", "Suse", "Windows"], families.map(&:value).sort
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

    test "OSes without a shorten_description method fall back to description" do
      assert_equal 'Arch Linux', Archlinux.shorten_description("Arch Linux")
    end
  end

end
