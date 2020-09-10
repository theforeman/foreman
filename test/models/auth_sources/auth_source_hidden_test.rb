require 'test_helper'

class AuthSourceHiddenTest < ActiveSupport::TestCase
  test "#authenticate returns nil" do
    refute AuthSourceHidden.new.authenticate('unknown user', 'secret')
  end

  test "#authenticate returns nil for known user" do
    u = FactoryBot.create(:user)
    refute AuthSourceHidden.new.authenticate(u.login, 'password')
  end

  test "cannot change password" do
    refute AuthSourceHidden.new.can_set_password?
  end

  test "#to_label returns HIDDEN" do
    assert_equal 'HIDDEN', AuthSourceHidden.new.to_label
  end
end
