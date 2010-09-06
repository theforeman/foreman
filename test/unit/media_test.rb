require 'test_helper'

class MediaTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end

  test "name can't be blank" do
    media = Media.new :name => "   ", :path => "http://www.google.com"
    assert media.name.strip.empty?
    assert !media.save
  end

  test "name can't contain white spaces" do
    media = Media.new :name => "   Archlinux mirror   thing   ", :path => "http://www.google.com"
    assert !media.name.strip.squeeze(" ").empty?
    assert !media.save

    media.name.strip!.squeeze!(" ")
    assert media.save!
  end

  test "name must be unique" do
    media = Media.new :name => "Archlinux mirror", :path => "http://www.google.com"
    assert media.save!

    other_media = Media.new :name => "Archlinux mirror", :path => "http://www.youtube.com"
    assert !other_media.save
  end

  test "path can't be blank" do
    media = Media.new :name => "Archlinux mirror", :path => "  "
    assert media.path.strip.empty?
    assert !media.save
  end

  test "path must be unique" do
    media = Media.new :name => "Archlinux mirror", :path => "http://www.google.com"
    assert media.save!

    other_media = Media.new :name => "Ubuntu mirror", :path => "http://www.google.com"
    assert !other_media.save
  end

  test "should not destroy while using" do
    media = Media.new :name => "Archlinux mirror", :path => "http://www.google.com"
    assert media.save!

    host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition",
      :ptable => Ptable.first
    assert host.save!

    media.hosts << host

    assert !media.destroy
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_medias"
      role.permissions = ["#{operation}_medias".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Media.create :name => "dummy", :path => "http://hello"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Media.create :name => "dummy", :path => "http://hello"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Media.first
    as_admin do
      record.hosts = []
    end
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Media.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Media.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Media.first
    record.name = "renamed"
    as_admin do
      record.hosts = []
    end
    assert !record.save
    assert record.valid?
  end

end
