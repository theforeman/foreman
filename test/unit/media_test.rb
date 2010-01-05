require 'test_helper'

class MediaTest < ActiveSupport::TestCase
  test "name can't be blank" do
    media = Media.new :name => "   ", :path => "http://www.google.com"
    assert media.name.strip.empty?
    assert !media.save
  end

  test "name can't contain white spaces" do
    media = Media.new :name => "   Archlinux mirror   thing   ", :path => "http://www.google.com"
    assert !media.name.strip.empty?
    assert !media.save

    media.name.strip!.tr!(' ', '')
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

    assert !operating_system.destroy
  end
end
