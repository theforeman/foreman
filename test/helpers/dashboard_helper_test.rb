require 'test_helper'

class DashboardHelperTest < ActionView::TestCase
  include DashboardHelper

  setup do
    Foreman::Plugin.report_origin_registry.stubs(:origins_for).with('ConfigReport').returns(['Puppet', 'Salt'])
    stubs(:origin_setting).with('Puppet', 'out_of_sync_disabled').returns(true)
  end

  test 'out of sync is disabled when every report origin disables it' do
    stubs(:origin_setting).with('Salt', 'out_of_sync_disabled').returns(true)

    refute out_of_sync_enabled?(nil)
  end

  test 'out of sync is enabled when one report origin enables it' do
    stubs(:origin_setting).with('Salt', 'out_of_sync_disabled').returns(false)

    assert out_of_sync_enabled?(nil)
  end
end
