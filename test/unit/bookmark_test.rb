require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  test "my bookmarks should contain all public bookmarks" do
    assert_equal Bookmark.my_bookmarks.include?(bookmarks(:one)), true
  end

  test "my bookmarks should not contain private bookmarks" do
    enable_login do
      assert_equal Bookmark.my_bookmarks.include?(bookmarks(:two)), false
    end
  end

  test "my bookmarks should contain my private bookmarks" do
    enable_login do
      assert_difference('Bookmark.count') do
        Bookmark.create({:name => "private", :query => "bar", :public => false, :controller => "hosts"})
      end
      assert_equal Bookmark.my_bookmarks.include?(Bookmark.find_by_name("private")), true
    end
  end

  test "validation fails when invalid controller name stored" do
    b = Bookmark.create :name => "controller_test", :controller => "hosts", :query => "foo=bar", :public => true
    assert b.valid?
    b.controller = "foo bar"
    refute b.valid?
  end

  test "save bookmarks from STI controllers" do
    FactoryGirl.create(:permission, :resource_type => 'ProvisioningTemplate', :name => 'manage_provisioning_templates')
    FactoryGirl.create(:permission, :resource_type => 'MyPlugin', :name => 'view_my_plugins')
    Permission.reset_resources
    b = FactoryGirl.build(:bookmark, :name => 'STI controller', :controller => 'provisioning_templates', :query => 'foo=bar', :public => true)
    assert(b.valid?, 'STI controller bookmark should be valid')
    b = FactoryGirl.build(:bookmark, :name => 'My plugin controller', :controller => 'my_plugins', :query => 'foo=bar', :public => true)
    assert(b.valid?, 'plugin controller bookmark should be valid')
  end

  private

  def enable_login(&block)
    login = SETTINGS[:login]
    user  = User.current
    SETTINGS[:login] = true
    User.current = users(:one)
    yield
    User.current = user
    SETTINGS[:login] = login
  end
end
