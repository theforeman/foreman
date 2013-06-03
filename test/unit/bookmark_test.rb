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
    assert_not b.valid?
  end

  private

  def enable_login &block
    login            = SETTINGS[:login]
    SETTINGS[:login] = true
    User.current = users(:one)
    yield
    SETTINGS[:login] = login
  end
end
