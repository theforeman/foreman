require 'test_helper'

class MediumTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
    disable_orchestration
  end

  test "name can't be blank" do
    medium = Medium.new :name => "   ", :path => "http://www.google.com"
    assert medium.name.strip.empty?
    assert !medium.save
  end

  test "name can't contain white spaces" do
    medium = Medium.new :name => "   Archlinux mirror   thing   ", :path => "http://www.google.com"
    assert !medium.name.squeeze(" ").empty?
    assert !medium.save

    medium.name = "Archlinux mirror      thing"
    assert !medium.save

    medium.name.squeeze!(" ")
    assert medium.save!
  end

  test "name must be unique" do
    medium = Medium.new :name => "Archlinux mirror", :path => "http://www.google.com"
    assert medium.save!

    other_medium = Medium.new :name => "Archlinux mirror", :path => "http://www.youtube.com"
    assert !other_medium.save
  end

  test "path can't be blank" do
    medium = Medium.new :name => "Archlinux mirror", :path => "  "
    assert medium.path.strip.empty?
    assert !medium.save
  end

  test "path must be unique" do
    medium = Medium.new :name => "Archlinux mirror", :path => "http://www.google.com"
    assert medium.save!

    other_medium = Medium.new :name => "Ubuntu mirror", :path => "http://www.google.com"
    assert !other_medium.save
  end

  test "should not destroy while using" do
    medium = Medium.new :name => "Archlinux mirror", :path => "http://www.google.com"
    assert medium.save!

    host = hosts(:one)
    host.medium = medium
    host.os.media << medium
    assert host.save!

    medium.hosts << host

    assert !medium.destroy
  end

  def setup_user operation
    super operation, "media"
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Medium.create :name => "dummy", :path => "http://hello"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Medium.create :name => "dummy", :path => "http://hello"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Medium.first
    as_admin do
      record.hosts.delete_all
      record.hostgroups.delete_all
      assert record.destroy
    end
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Medium.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Medium.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Medium.first
    record.name = "renamed"
    as_admin do
      record.hosts.delete_all
    end
    assert !record.save
    assert record.valid?
  end

  test "os family can be one of defined os families" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => Operatingsystem.families[0]
    assert medium.valid?
  end

  test "os family can't be anything else than defined os families" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => "unknown"
    assert !medium.valid?
  end

  test "os family can be nil" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => nil
    assert medium.valid?
  end

  test "setting os family to a blank string is valid" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => ""
    assert medium.valid?
  end

  test "blank os family is saved as nil" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => ""
    assert_equal nil, medium.os_family
  end

end
