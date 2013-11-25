require 'test_helper'

class ExternalUsergroupTest < ActiveSupport::TestCase
  test "should not be able to use hidden auth source" do
    eug = FactoryGirl.build(:external_usergroup, :auth_source => AuthSourceHidden.first)
    refute_valid eug, :auth_source, /permitted/
  end
end
