require 'test_helper'

class ObservableJobTest < ActiveSupport::TestCase
  describe '#set_hook' do
    let(:job) { job_class.new({ "a_string" => 1, :a_symbol => 1 }) }
    let(:job_class) do
      Class.new(ApplicationJob) do
        include ::Foreman::ObservableJob

        def perform(options = {})
        end

        set_hook :job_performed
        set_hook :job_performed_with_payload, payload: { custom_payload: true }
        set_hook :job_performed_with_block do |serialized_job|
          { a_string: serialized_job["arguments"].first["a_string"], block: true }
        end
      end
    end
    let(:callback) { -> {} }
    let(:event_context) { ::Logging.mdc.context.symbolize_keys.with_indifferent_access }

    test 'event subscription hooks are defined in the the job class' do
      expected_event_subscription_hooks = [
        'job_performed.event.foreman',
        'job_performed_with_payload.event.foreman',
        'job_performed_with_block.event.foreman',
      ]

      assert_same_elements expected_event_subscription_hooks, job_class.event_subscription_hooks
    end

    test 'notify with event context' do
      ActiveSupport::Notifications.subscribed(callback, 'job_performed.event.foreman') do
        callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
          payload[:context] == event_context
        end

        job.perform_now
      end
    end

    test 'notify with default payload' do
      ActiveSupport::Notifications.subscribed(callback, 'job_performed.event.foreman') do
        callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
          # arguments in serialized active job are always strings
          [payload["arguments"].first["a_string"], payload["arguments"].first["a_symbol"]] == [1, 1]
        end

        job.perform_now
      end
    end

    test 'notify with custom payload' do
      ActiveSupport::Notifications.subscribed(callback, 'job_performed_with_payload.event.foreman') do
        callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
          payload[:custom_payload] == true
        end

        job.perform_now
      end
    end

    test 'notify with block payload' do
      ActiveSupport::Notifications.subscribed(callback, 'job_performed_with_block.event.foreman') do
        callback.expects(:call).with do |name, _started, _finished, _unique_id, payload|
          payload["a_string"] == 1 && payload[:block] == true
        end

        job.perform_now
      end
    end
  end
end
