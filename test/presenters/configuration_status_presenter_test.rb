require 'test_helper'

class ConfigurationStatusPresenterTest < ActiveSupport::TestCase
  describe 'total data' do
    subject { HostStatus::ConfigurationStatus.presenter.send(:total_data) }

    let(:host) { FactoryBot.create(:host, reports: reports, last_report: reports.first&.reported_at) }
    let(:reports) { [report] }
    let(:report) { FactoryBot.build(:report, :with_origin, status: status, reported_at: reported_at) }
    let(:status) { {} }
    let(:reported_at) { Time.now.utc }

    setup do
      Setting[:always_show_configuration_status] = true

      HostStatus::ConfigurationStatus.create(host: host).tap(&:refresh!)
    end

    context 'when not relevant' do
      let(:reports) { [] }

      setup do
        Setting[:always_show_configuration_status] = false
      end

      it { assert_equal 1, HostStatus::ConfigurationStatus.count }
      it { assert_empty subject.keys }
    end

    context 'when alerts disabled' do
      let(:host) { FactoryBot.create(:host, enabled: false) }

      it { assert_equal 1, HostStatus::ConfigurationStatus.count }
      it { assert_equal 1, subject[HostStatus::ConfigurationStatus::ALERTS_DISABLED] }
    end

    context 'when no reports' do
      let(:reports) { [] }

      it { assert_equal 1, HostStatus::ConfigurationStatus.count }
      it { assert_equal 1, subject[HostStatus::ConfigurationStatus::NO_REPORTS] }
    end

    context 'when pending' do
      let(:status) do
        {
          applied: 1,
          restarted: 1,
          failed: 1,
          failed_restarts: 1,
          skipped: 1,
          pending: 1,
        }
      end

      it { assert_equal 1, HostStatus::ConfigurationStatus.count }
      it { assert_nil subject[HostStatus::ConfigurationStatus::PENDING] }
    end

    context 'when out of sync' do
      let(:reported_at) { Time.now.utc - Setting[:outofsync_interval].minutes - 1.hour }

      it { assert_equal 1, HostStatus::ConfigurationStatus.count }
      it { assert host.get_status(HostStatus::ConfigurationStatus).out_of_sync? }
      it { assert_equal 1, subject[HostStatus::ConfigurationStatus::OUT_OF_SYNC] }

      context 'and out of sync disabled' do
        setup do
          Foreman.settings._add("#{report.origin}_out_of_sync_disabled",
            context: :test,
            type: :boolean,
            category: 'Setting::General',
            full_name: 'Test out of sync',
            description: 'description',
            default: false)
          Setting[:"#{report.origin}_out_of_sync_disabled"] = true
        end

        it { assert_equal 1, HostStatus::ConfigurationStatus.count }
        it { assert_not host.get_status(HostStatus::ConfigurationStatus).out_of_sync? }
        it { assert_nil subject[HostStatus::ConfigurationStatus::OUT_OF_SYNC] }
      end

      context 'and origin interval set via settings' do
        let(:origin_interval) { 10 }
        let(:reported_at) { Time.now.utc - origin_interval.minutes - 5.minutes }

        setup do
          Foreman.settings._add("#{report.origin}_interval",
            context: :test,
            type: :integer,
            category: 'Setting::General',
            full_name: 'Origin out of sync interval',
            description: 'description',
            default: 0)
          Setting[:"#{report.origin}_interval"] = origin_interval
        end

        it { assert_equal 1, HostStatus::ConfigurationStatus.count }
        it { assert host.get_status(HostStatus::ConfigurationStatus).out_of_sync? }
        it { assert_equal 1, subject[HostStatus::ConfigurationStatus::OUT_OF_SYNC] }
      end

      context 'and origin interval set via host parameters' do
        let(:origin_interval) { 10 }
        let(:reported_at) { Time.now.utc - origin_interval.minutes - 5.minutes }

        setup do
          host.host_parameters.create!(name: "#{report.origin}_interval", value: origin_interval)
        end

        it { assert_equal 1, HostStatus::ConfigurationStatus.count }
        it { assert host.get_status(HostStatus::ConfigurationStatus).out_of_sync? }
        it { assert_equal 1, subject[HostStatus::ConfigurationStatus::OUT_OF_SYNC] }
      end
    end

    context 'when error' do
      context 'and failed' do
        let(:status) do
          {
            applied: 1,
            restarted: 1,
            failed: 1,
            failed_restarts: 0,
            skipped: 1,
            pending: 0,
          }
        end

        it { assert_equal 1, HostStatus::ConfigurationStatus.count }
        it { assert_equal 1, subject[HostStatus::ConfigurationStatus::ERROR] }
      end

      context 'and failed restart' do
        let(:status) do
          {
            applied: 1,
            restarted: 1,
            failed: 0,
            failed_restarts: 1,
            skipped: 1,
            pending: 0,
          }
        end

        it { assert_equal 1, HostStatus::ConfigurationStatus.count }
        it { assert_equal 1, subject[HostStatus::ConfigurationStatus::ERROR] }
      end
    end

    context 'when active' do
      context 'and applied' do
        let(:status) do
          {
            applied: 1,
            restarted: 0,
            failed: 0,
            failed_restarts: 0,
            skipped: 1,
            pending: 0,
          }
        end

        it { assert_equal 1, HostStatus::ConfigurationStatus.count }
        it { assert_equal 1, subject[HostStatus::ConfigurationStatus::ACTIVE] }
      end

      context 'and restarted' do
        let(:status) do
          {
            applied: 0,
            restarted: 1,
            failed: 0,
            failed_restarts: 0,
            skipped: 1,
            pending: 0,
          }
        end

        it { assert_equal 1, HostStatus::ConfigurationStatus.count }
        it { assert_equal 1, subject[HostStatus::ConfigurationStatus::ACTIVE] }
      end
    end

    context 'when no changes' do
      let(:status) do
        {
          applied: 0,
          restarted: 0,
          failed: 0,
          failed_restarts: 0,
          skipped: 0,
          pending: 0,
        }
      end

      it { assert_equal 1, HostStatus::ConfigurationStatus.count }
      it { assert_equal 1, subject[HostStatus::ConfigurationStatus::NO_CHANGES] }

      context 'and skipped' do
        let(:status) do
          {
            applied: 0,
            restarted: 0,
            failed: 0,
            failed_restarts: 0,
            skipped: 1,
            pending: 0,
          }
        end

        it { assert_equal 1, HostStatus::ConfigurationStatus.count }
        it { assert_equal 1, subject[HostStatus::ConfigurationStatus::NO_CHANGES] }
      end
    end
  end
end
