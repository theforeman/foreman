require 'test_helper'

class AuthSourceInternalTest < ActiveSupport::TestCase
  test "#authenticate returns nil when username is blank" do
    refute AuthSourceInternal.new.authenticate('', 'secret')
  end

  test "#authenticate returns nil when password is blank" do
    refute AuthSourceInternal.new.authenticate('foobar', '')
  end

  test "#authenticate returns nil for unknown user" do
    refute AuthSourceInternal.new.authenticate('unknown user account', 'secret')
  end

  test "#authenticate returns nil when User#matching_password? fails" do
    u = FactoryBot.create(:user)
    User.any_instance.expects(:matching_password?).with('password').returns(false)
    refute AuthSourceInternal.new.authenticate(u.login, 'password')
  end

  test "#authenticate returns true when User#matching_password? succeeds" do
    u = FactoryBot.create(:user)
    User.any_instance.expects(:matching_password?).with('password').returns(true)
    assert AuthSourceInternal.new.authenticate(u.login, 'password')
  end

  test "can change password" do
    assert AuthSourceInternal.new.can_set_password?
  end

  test "#to_label returns INTERNAL" do
    assert_equal 'INTERNAL', AuthSourceInternal.new.to_label
  end
end
