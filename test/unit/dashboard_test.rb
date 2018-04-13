require 'test_helper'

class DashboardTest < ActiveSupport::TestCase
  setup do
    @env = FactoryBot.build(:environment)
    @host = FactoryBot.create(:host, :with_reports, :environment => @env)
  end

  test 'hosts returns correct host' do
    data = Dashboard::Data.new

    as_admin do
      assert_equal 1, data.hosts.length
    end
  end

  test 'hosts works with environment filter' do
    data = Dashboard::Data.new("environment = #{@env.name}")

    as_admin do
      assert_equal 1, data.hosts.length
    end
  end

  test 'hosts works with free text filter' do
    data = Dashboard::Data.new(@env.name)

    as_admin do
      assert_equal 1, data.hosts.length
    end
  end

  test 'hosts works with a filter that returns no hosts' do
    data = Dashboard::Data.new("name = DoesNotExist")

    as_admin do
      assert_equal 0, data.hosts.length
    end
  end

  test 'latest_events does not return uneventful reports' do
    data = Dashboard::Data.new

    as_admin do
      assert_equal 0, data.latest_events.length
    end
  end

  context 'with eventful report' do
    setup do
      @host.reports.first.update_attribute(:status, 2)
    end

    test 'latest_events returns latest events' do
      data = Dashboard::Data.new

      as_admin do
        assert_equal 1, data.latest_events.length
      end
    end

    test 'latest_events works with environment filter' do
      data = Dashboard::Data.new("environment = #{@env.name}")

      as_admin do
        assert_equal 1, data.latest_events.length
      end
    end

    test 'latest_events works with free text filter' do
      data = Dashboard::Data.new(@env.name)

      as_admin do
        assert_equal 1, data.latest_events.length
      end
    end

    test 'latest_events works with a filter that returns no hosts' do
      data = Dashboard::Data.new("name = DoesNotExist")

      as_admin do
        assert_equal 0, data.latest_events.length
      end
    end

    test 'latest_events does not fail on ambiguous column name host_id' do
      data = Dashboard::Data.new
      # instead of going through the authorizer, force a join that will cause ambiguity.
      ConfigReport.expects(:authorized).with(:view_config_reports).returns(ConfigReport.joins(:host => :interfaces))
      as_admin do
        assert_equal 1, data.latest_events.length
      end
    end
  end
end
