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
        original, Setting[:destroy_vm_on_host_delete] = Setting[:destroy_vm_on_host_delete], true
        host.destroy!
        assert_includes host.queue.items.map(&:name), "Removing compute instance #{host.name}"
      ensure
        Setting[:destroy_vm_on_host_delete] = original
      end

      test 'it disassociates the host if destroy_vm_on_host_delete setting is disabled' do
        original, Setting[:destroy_vm_on_host_delete] = Setting[:destroy_vm_on_host_delete], false
        host.destroy!
        refute_includes host.queue.items.map(&:name), "Removing compute instance #{host.name}"
      ensure
        Setting[:destroy_vm_on_host_delete] = original
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

    describe 'a sparc host' do
      let(:medium) { FactoryBot.create(:medium, :solaris) }
      let(:architecture) { architectures(:sparc) }
      let(:os) { FactoryBot.create(:solaris, architectures: [architecture], media: [medium]) }
      let(:host) { FactoryBot.create(:host, :managed, operatingsystem: os, architecture: architecture) }

      setup do
        Resolv::DNS.any_instance.stubs(:getaddress).returns('2.3.4.5')
      end

      it 'has an install_path' do
        assert_equal '/vol/solgi_5.10/sol8__sparc', host.install_path
      end

      it 'has a jumpstart_path' do
        assert_equal '2.3.4.5:/vol/jumpstart', host.jumpstart_path
      end

      it 'has a multiboot' do
        assert_equal 'boot/Solaris-10.8-multiboot', host.multiboot
      end

      it 'has a miniroot' do
        assert_equal 'boot/Solaris-10.8-x86.miniroot', host.miniroot
      end
    end

    describe 'hooks' do
      let(:host) { FactoryBot.create(:host, :managed) }
      let(:event_context) { ::Logging.mdc.context.symbolize_keys.with_indifferent_access }
      let(:callback) { -> {} }

      test 'hooks are defined' do
        expected = [
          'host_created.event.foreman',
          'host_updated.event.foreman',
          'host_destroyed.event.foreman',
          'build_entered.event.foreman',
          'build_exited.event.foreman',
          'status_changed.event.foreman',
        ]

        assert_same_elements expected, Host::Managed.event_subscription_hooks
      end

      describe 'build_entered hook' do
        let(:host) { FactoryBot.create(:host, :managed, build: false) }

        test '"build_entered.event.foreman" event is sent when build set to true' do
          host.update!(build: false)

          ActiveSupport::Notifications.subscribed(callback, 'build_entered.event.foreman') do
            callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
              payload[:hostname] == host.hostname
            end

            host.setBuild
          end
        end
      end

      describe 'build_exited hook' do
        let(:host) { FactoryBot.create(:host, :managed, build: true) }

        test '"build_exited.event.foreman" event is sent when build set to false' do
          ActiveSupport::Notifications.subscribed(callback, 'build_exited.event.foreman') do
            callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
              payload[:hostname] == host.hostname
            end

            host.built
          end
        end
      end

      describe 'status_changed hook' do
        let(:host) { FactoryBot.create(:host, :managed, global_status: 0) }

        test '"status_changed.event.foreman" event is sent when global status was changed' do
          ActiveSupport::Notifications.subscribed(callback, 'status_changed.event.foreman') do
            callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
              payload[:global_status] == { "from" => 0, "to" => 1 }
            end

            host.update(global_status: 1)
          end
        end
      end
    end

    describe 'AR hooks' do
      let(:host) { FactoryBot.build(:host, :managed) }

      test 'call #build_hooks on commit' do
        host.expects(:build_hooks)

        host.run_callbacks(:commit)
      end

      describe '#build_hooks' do
        context 'when build mode is enabled' do
          it 'runs :build callbacks' do
            host.stubs(:build?).returns(true)
            host.stubs(:previous_changes).returns({ 'build' => [false, true] })

            host.expects(:run_callbacks).with(:build)

            host.build_hooks
          end
        end

        context 'when build mode is disabled' do
          it 'runs :provision callbacks' do
            host.stubs(:build?).returns(false)
            host.stubs(:previous_changes).returns({ 'build' => [true, false] })

            host.expects(:run_callbacks).with(:provision)

            host.build_hooks
          end
        end
      end
    end

    context 'host registration' do
      let(:host) { FactoryBot.create(:host) }
      let(:jwt_secret) { 'wtLAhNwPI5JhsUk3LfA7tg==' }

      describe '#registration_token' do
        it 'generates a jwt token' do
          host.registration_facet!.update(jwt_secret: jwt_secret)
          token = host.registration_token.token
          payload = JWT.decode(token, jwt_secret, true).first
          assert_equal host.id, payload['host_id']
        end
      end

      describe '#registration_url' do
        it 'generates a registration url' do
          ForemanRegister::RegistrationToken.stubs(:encode).returns('some-jwt-token')
          assert_equal 'http://foreman.some.host.fqdn/foreman_register/hosts/register?token=some-jwt-token', host.registration_url
        end
      end
    end
  end
end
