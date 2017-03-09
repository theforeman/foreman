require 'test_helper'

class UINotificationsHostsTest < ActiveSupport::TestCase
  test 'notification audience should be user' do
    host.owner = FactoryGirl.build(:user)
    assert_equal 'user', audience
  end

  test 'notification audience should be usergroup' do
    host.owner = FactoryGirl.build(:usergroup)
    assert_equal 'usergroup', audience
  end

  test 'notification audience should be nil if there is no owner' do
    host.owner = nil
    assert_nil audience
  end

  test 'deliver! should not run if audience is nil' do
    host.owner = nil
    assert !base.deliver!
  end

  private

  def host
    @host ||= FactoryGirl.build(:host, :managed)
  end

  def base
    UINotifications::Hosts::Base.new(host)
  end

  def audience
    base.send(:audience)
  end
end
