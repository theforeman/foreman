require 'test_helper'

class BuildStatusTest < ActiveSupport::TestCase
  def setup
    @host = FactoryGirl.build(:host)
    @status = HostStatus::BuildStatus.new
    @status.host = @host
  end

  test 'is valid' do
    assert_valid @status
  end

  test '#to_label changes based on waiting_for_build?' do
    @status.stub(:waiting_for_build?, true) do
      assert_equal 'Pending installation', @status.to_label
    end

    @status.stub(:waiting_for_build?, false) do
      assert_equal 'Installed', @status.to_label
    end
  end

  test '#relevant? is only for managed hosts in unattended mode' do
    @host.managed = true
    assert @status.relevant?

    original, SETTINGS[:unattended] = SETTINGS[:unattended], false
    refute @status.relevant?
    SETTINGS[:unattended] = original

    @host.managed = false
    refute @status.relevant?
  end

  test '#waiting_for_build? verifies build flag and host relation' do
    refute @status.waiting_for_build?

    @status.host.build = true
    assert @status.waiting_for_build?

    @status.host = nil
    refute @status.waiting_for_build?
  end
end
