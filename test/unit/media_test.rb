require 'test_helper'

class MediaTest < ActiveSupport::TestCase
  test "name can't be blank" do
    media = Media.new :name => "   ", :path => "http://www.google.com"
    assert media.name.strip.empty?
    assert !media.save
  end

  test "name can't contain whitespaces" do
    media = Media.new :name => "   Archlinux mirror   thing   ", :path => "http://www.google.com"
    assert !media.name.strip.empty?
    assert !media.save

    media = Media.new :name => "Archlinux mirror   thing", :path => "http://www.google.com"
    assert !media.name.strip.empty?
    assert !media.save
  end

  test "path can't be blank" do
    media = Media.new :name => "Archlinux mirror", :path => "  "
    assert media.path.strip.empty?
    assert !media.save
  end
end
