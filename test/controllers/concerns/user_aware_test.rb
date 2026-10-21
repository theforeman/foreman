require 'test_helper'

class UserAwareTestController < ApplicationController
  include Foreman::Controller::UserAware

  public :find_authorized_user
end

class UserAwareTest < ActiveSupport::TestCase
  def setup
    @controller = UserAwareTestController.new
    @caller = FactoryBot.create(:user)
    User.current = @caller
  end

  test 'finds the current user when editing self' do
    @controller.stubs(:editing_self?).returns(true)

    assert_equal @caller, @controller.find_authorized_user(:edit_users)
  end

  test 'finds a user authorized by the requested permission' do
    target = as_admin { FactoryBot.create(:user) }
    setup_user('edit', 'users', nil, @caller)
    stub_user_id(target)

    assert_equal target, @controller.find_authorized_user(:edit_users)
  end

  test 'does not find a user outside the permission filter' do
    allowed_user = as_admin { FactoryBot.create(:user) }
    target = as_admin { FactoryBot.create(:user) }
    setup_user('edit', 'users', "id = #{allowed_user.id}", @caller)
    stub_user_id(target)

    assert_nil @controller.find_authorized_user(:edit_users)
  end

  test 'does not find a hidden user' do
    setup_user('edit', 'users', nil, @caller)
    stub_user_id(users(:apiadmin))

    assert_nil @controller.find_authorized_user(:edit_users)
  end

  private

  def stub_user_id(user)
    @controller.stubs(:editing_self?).returns(false)
    @controller.stubs(:params).returns(ActionController::Parameters.new(:user_id => user.id))
  end
end
