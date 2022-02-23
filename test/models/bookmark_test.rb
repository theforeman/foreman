require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  should allow_values(*valid_name_list).for(:name)
  should allow_values(*valid_name_list).for(:query)
  should_not allow_values(*invalid_name_list).for(:name)
  should_not allow_values('', ' ').for(:query)

  test "my bookmarks should contain all public bookmarks" do
    assert_equal Bookmark.my_bookmarks.include?(bookmarks(:one)), true
  end

  test "my bookmarks should not contain private bookmarks" do
    as_user :one do
      assert_equal Bookmark.my_bookmarks.include?(bookmarks(:two)), false
    end
  end

  test "should create with multiple valid controllers" do
    valid_controller_values = (["dashboard", "common_parameters"] +
      ActiveRecord::Base.connection.tables.map(&:to_s) +
      Permission.resources.map(&:tableize)).uniq
    BookmarkControllerValidator.reset_controllers_list
    valid_controller_values.each do |controller|
      bookmark = FactoryBot.create(:bookmark, :controller => controller, :public => false)
      assert bookmark.valid?, "Can't create bookmark with valid controller #{controller}"
    end
  end

  test "should update with multiple valid names" do
    bookmark = FactoryBot.create(:bookmark, :controller => "hosts", :public => false)
    valid_name_list.each do |name|
      bookmark.name = name
      assert bookmark.valid?, "Can't update bookmark with valid name #{name}"
    end
  end

  test "should update with multiple valid queries" do
    bookmark = FactoryBot.create(:bookmark, :controller => "hosts", :public => false)
    valid_name_list.each do |query|
      bookmark.query = query
      assert bookmark.valid?, "Can't update bookmark with valid query #{query}"
    end
  end

  test "should not update with multiple invalid names" do
    bookmark = FactoryBot.create(:bookmark, :controller => "hosts", :public => false)
    invalid_name_list.each do |name|
      bookmark.name = name
      refute bookmark.valid?, "Can update bookmark with invalid name #{name}"
      assert_includes bookmark.errors.attribute_names, :name
    end
  end

  test "my bookmarks should contain my private bookmarks" do
    assert_difference('Bookmark.count') do
      Bookmark.create({:name => "private", :query => "bar", :public => false, :controller => "hosts"})
    end
    assert_equal Bookmark.my_bookmarks.include?(Bookmark.find_by_name("private")), true
  end

  test "my bookmarks should be able to create two bookmarks with same name under different controllers" do
    assert_difference 'Bookmark.count', 1 do
      FactoryBot.create(:bookmark, :name => 'private', :controller => "users")
      bookmark = FactoryBot.build_stubbed(:bookmark, :name => 'private', :controller => "hosts")
      assert_valid bookmark
    end
  end

  test "validation fails when invalid controller name stored" do
    b = Bookmark.create :name => "controller_test", :controller => "hosts", :query => "foo=bar", :public => true
    assert b.valid?
    b.controller = "foo bar"
    refute b.valid?
  end

  test "save bookmarks from STI controllers" do
    FactoryBot.create(:permission, :resource_type => 'ProvisioningTemplate', :name => 'manage_provisioning_templates')
    FactoryBot.create(:permission, :resource_type => 'MyPlugin', :name => 'view_my_plugins')
    Permission.reset_resources
    BookmarkControllerValidator.reset_controllers_list
    b = FactoryBot.build_stubbed(:bookmark, :name => 'STI controller', :controller => 'provisioning_templates', :query => 'foo=bar', :public => true)
    assert(b.valid?, 'STI controller bookmark should be valid')
    b = FactoryBot.build_stubbed(:bookmark, :name => 'My plugin controller', :controller => 'my_plugins', :query => 'foo=bar', :public => true)
    assert(b.valid?, 'plugin controller bookmark should be valid')
  end

  test "public should default to false" do
    bookmark = Bookmark.new({:name => "private", :query => "bar", :controller => "hosts"})
    assert_equal(false, bookmark.public)
    assert bookmark.valid?
    bookmark.public = nil
    refute bookmark.valid?
  end
end
