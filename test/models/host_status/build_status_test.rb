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

  # Helper to evaluate computed_status_sql for a single host via the database
  def sql_status_for(host)
    HostStatus::BuildStatus
      .joins(:host)
      .joins(HostStatus::BuildStatus.computed_status_joins)
      .where(host_id: host.id)
      .pick(Arel.sql(HostStatus::BuildStatus.computed_status_sql))
  end

  test 'to_status and computed_status_sql agree when token_duration is 0 and expired token exists' do
    Setting[:token_duration] = 30
    host = FactoryBot.create(:host, :managed, :build => true)
    host.set_token
    host.save!
    host.token.update!(expires: 1.hour.ago)
    Setting[:token_duration] = 0

    status = HostStatus::BuildStatus.find_by(host_id: host.id) || HostStatus::BuildStatus.create!(host: host)
    assert_equal status.to_status, sql_status_for(host),
      'Ruby and SQL should both return PENDING when token_duration is 0, even with an expired token'
  end

  test 'to_status and computed_status_sql agree when token_duration is nonzero and token is expired' do
    Setting[:token_duration] = 30
    host = FactoryBot.create(:host, :managed, :build => true)
    host.set_token
    host.save!
    host.token.update!(expires: 1.hour.ago)

    status = HostStatus::BuildStatus.find_by(host_id: host.id) || HostStatus::BuildStatus.create!(host: host)
    assert_equal HostStatus::BuildStatus::TOKEN_EXPIRED, status.to_status
    assert_equal status.to_status, sql_status_for(host)
  end

  test 'to_status and computed_status_sql agree when host is building with no token' do
    Setting[:token_duration] = 0
    host = FactoryBot.create(:host, :managed, :build => true)

    status = HostStatus::BuildStatus.find_by(host_id: host.id) || HostStatus::BuildStatus.create!(host: host)
    assert_equal HostStatus::BuildStatus::PENDING, status.to_status
    assert_equal status.to_status, sql_status_for(host)
  end

  test 'to_status and computed_status_sql agree when host is building with valid token' do
    Setting[:token_duration] = 30
    host = FactoryBot.create(:host, :managed, :build => true)
    host.set_token
    host.save!

    status = HostStatus::BuildStatus.find_by(host_id: host.id) || HostStatus::BuildStatus.create!(host: host)
    assert_equal HostStatus::BuildStatus::PENDING, status.to_status
    assert_equal status.to_status, sql_status_for(host)
  end

  test 'to_status and computed_status_sql agree when host is built' do
    host = FactoryBot.create(:host, :managed, :build => false)

    status = HostStatus::BuildStatus.find_by(host_id: host.id) || HostStatus::BuildStatus.create!(host: host)
    assert_equal HostStatus::BuildStatus::BUILT, status.to_status
    assert_equal status.to_status, sql_status_for(host)
  end

  test 'to_status and computed_status_sql agree when host has build errors' do
    host = FactoryBot.create(:host, :managed, :build => false)
    host.update_column(:build_errors, 'something went wrong')

    status = HostStatus::BuildStatus.find_by(host_id: host.id) || HostStatus::BuildStatus.create!(host: host)
    assert_equal HostStatus::BuildStatus::BUILD_FAILED, status.to_status
    assert_equal status.to_status, sql_status_for(host)
  end
end
