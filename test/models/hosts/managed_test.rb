require 'test_helper'

module Host
  class ManagedTest < ActiveSupport::TestCase
    describe 'validations' do
      subject do
        FactoryBot.build(:host, :managed)
      end
      should validate_uniqueness_of(:uuid)
    end

    describe 'deletion' do
      let(:host) { FactoryBot.create(:host, :on_compute_resource) }

      test 'it tries to delete the vm in case destroy_vm_on_host_delete is enabled' do
        begin
          original, Setting[:destroy_vm_on_host_delete] = Setting[:destroy_vm_on_host_delete], true
          host.destroy!
          assert_includes host.queue.items.map(&:name), "Removing compute instance #{host.name}"
        ensure
          Setting[:destroy_vm_on_host_delete] = original
        end
      end

      test 'it disassociates the host if destroy_vm_on_host_delete setting is disabled' do
        begin
          original, Setting[:destroy_vm_on_host_delete] = Setting[:destroy_vm_on_host_delete], false
          host.destroy!
          refute_includes host.queue.items.map(&:name), "Removing compute instance #{host.name}"
        ensure
          Setting[:destroy_vm_on_host_delete] = original
        end
      end
    end

    describe 'Scopes' do
      subject { Host::Managed }
      let(:host) { FactoryBot.create(:host, :with_reports, :managed) }
      let(:past_time) { Time.now - (Setting[:outofsync_interval] * 2).minutes }
      let(:out_of_sync_host) do
        FactoryBot.create(:host, :with_reports, :managed)
      end

      setup do
        host.save
        out_of_sync_host.update_attribute(:last_report, past_time)
      end

      describe '.recent' do
        test 'returns hosts recently reported' do
          assert subject.recent.include?(host)
          refute subject.recent.include?(out_of_sync_host)
        end
      end

      describe '.out_of_sync' do
        test 'returns hosts not recently reported' do
          refute subject.out_of_sync.include?(host)
          assert subject.out_of_sync.include?(out_of_sync_host)
        end
      end

      context 'with hosts reporting an origin' do
        let(:fake_origin) { 'fake_origin' }
        let(:host_with_origin) do
          new_host = FactoryBot.create(:host, :with_reports, :managed)
          new_host.reports.each do |report|
            report.update_attribute(:origin, fake_origin)
          end
          new_host
        end

        setup do
          Foreman::Plugin.report_origin_registry
                         .stubs(:all_origins)
                         .returns([fake_origin])
          host_with_origin.update_attribute(:last_report, past_time)
          out_of_sync_host.update_attribute(:last_report, past_time)
        end

        describe '.out_of_sync' do
          test 'returns all hosts even with an origin' do
            assert subject.out_of_sync
                          .include?(host_with_origin)
            assert subject.out_of_sync
                          .include?(out_of_sync_host)
            refute subject.out_of_sync
                          .include?(host)
          end
        end

        describe '.out_of_sync_for' do
          test 'returns only hosts out of sync with in an origin' do
            assert subject.out_of_sync_for(fake_origin)
                          .include?(host_with_origin)
            refute subject.out_of_sync_for(fake_origin)
                          .include?(out_of_sync_host)
          end
        end
      end
    end
  end
end
