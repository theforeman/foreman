require 'test_helper'

class BuildStatusTest < ActiveSupport::TestCase
  def setup
    @host = FactoryBot.build_stubbed(:host)
    @status = HostStatus::BuildStatus.new
    @status.host = @host
  end

  test 'is valid' do
    assert_valid @status
  end

  # waiting_for_build?, token_expired?, expectation
  [
    [true,  false, 'Pending installation'],
    [true,  true,  'Token expired'],
    [false, true,  'Installed'],
    [false, false, 'Installed'],
  ].each do |waiting_for_build, token_expired, expectation|
    test "#to_label reflects waiting_for_build? = #{waiting_for_build} and token_expired? = #{token_expired}" do
      @status.stub(:waiting_for_build?, waiting_for_build) do
        @status.stub(:token_expired?, token_expired) do
          assert_equal expectation, @status.to_label
        end
      end
    end
  end

  test '#relevant? is true regardless of managed flag' do
    @host.managed = true
    assert @status.relevant?

    @host.managed = false
    assert @status.relevant?
  end

  test '#waiting_for_build? verifies build flag and host relation' do
    refute @status.waiting_for_build?

    @status.host.build = true
    assert @status.waiting_for_build?

    @status.host = nil
    refute @status.waiting_for_build?
  end
end
