require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  include UsersHelper

  describe 'homepages' do
    test 'with permission' do
      assert_not_empty homepages
    end

    test 'without permission' do
      as_user(:one) do
        assert_equal homepages, []
      end
    end
  end
end
