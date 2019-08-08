require 'test_helper'

class UserMenuTest < ActiveSupport::TestCase
  test 'should generate menu items for user' do
    as_user :view_hosts do
      menu = UserMenu.new.generate
      assert_equal 1, menu.size
    end
  end
end
