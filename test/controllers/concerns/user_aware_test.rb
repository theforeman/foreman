require 'test_helper'

class AuthorizedUserTestController < ApplicationController
  include Foreman::Controller::AuthorizedUser

  public :find_authorized_user
end

class AuthorizedUserTest < ActiveSupport::TestCase
  def setup
    @controller = AuthorizedUserTestController.new
    @caller = FactoryBot.create(:user)
    User.current = @caller
  end

  test 'finds the current user from an explicit mail notification identifier' do
    @controller.stubs(:params).returns(ActionController::Parameters.new(
      :controller => 'api/v2/mail_notifications',
      :action => 'user_mail_notifications',
      :id => @caller.id
    ))

    assert_equal @caller, @controller.find_authorized_user(:edit_users, @caller.id)
  end

  test 'does not apply self-service access to a different explicit user' do
    target = as_admin { FactoryBot.create(:user) }
    @controller.stubs(:params).returns(ActionController::Parameters.new(
      :controller => 'api/v2/mail_notifications',
      :action => 'user_mail_notifications',
      :id => @caller.id
    ))

    assert_nil @controller.find_authorized_user(:edit_users, target.id)
  end

  test 'finds a user authorized by the requested permission' do
    target = as_admin { FactoryBot.create(:user) }
    setup_user('edit', 'users', nil, @caller)
    stub_user_id(target)

    assert_equal target, @controller.find_authorized_user(:edit_users)
  end

  test 'finds an explicitly identified authorized user' do
    target = as_admin { FactoryBot.create(:user) }
    setup_user('edit', 'users', nil, @caller)
    @controller.stubs(:editing_self?).returns(false)

    assert_equal target, @controller.find_authorized_user(:edit_users, target.id)
  end

  test 'does not find a user outside the permission filter' do
    allowed_user = as_admin { FactoryBot.create(:user) }
    target = as_admin { FactoryBot.create(:user) }
    setup_user('edit', 'users', "id = #{allowed_user.id}", @caller)
    @controller.stubs(:editing_self?).returns(false)

    assert_nil @controller.find_authorized_user(:edit_users, target.id)
  end

  test 'does not find a hidden user' do
    setup_user('edit', 'users', nil, @caller)
    @controller.stubs(:editing_self?).returns(false)

    assert_nil @controller.find_authorized_user(:edit_users, users(:apiadmin).id)
  end

  test 'does not find a missing user' do
    setup_user('edit', 'users', nil, @caller)
    @controller.stubs(:editing_self?).returns(false)

    assert_nil @controller.find_authorized_user(:edit_users, User.maximum(:id) + 1)
  end

  private

  def stub_user_id(user)
    @controller.stubs(:editing_self?).returns(false)
    @controller.stubs(:params).returns(ActionController::Parameters.new(:user_id => user.id))
  end
end
