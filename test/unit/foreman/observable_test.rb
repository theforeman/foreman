require 'test_helper'

class ObservableTest < ActiveSupport::TestCase
  describe '#trigger_hook' do
    let(:object) { Class.new.include(::Foreman::Observable).new }
    let(:callback) { -> {} }
    let(:event_context) { ::Logging.mdc.context.symbolize_keys.with_indifferent_access }

    it 'triggers hook with payload' do
      ActiveSupport::Notifications.subscribed(callback, 'triggered.event.foreman') do
        callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
          payload[:foo] == :bar
        end

        object.trigger_hook(:triggered, payload: { foo: :bar })
      end
    end

    it 'triggers hook with block' do
      ActiveSupport::Notifications.subscribed(callback, 'triggered.event.foreman') do
        callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
          payload[:id] == object.object_id && payload[:block] == true
        end

        object.trigger_hook(:triggered) { |obj| { id: obj.object_id, block: true } }
      end
    end

    it 'triggers hook without payload and block' do
      ActiveSupport::Notifications.subscribed(callback, 'triggered.event.foreman') do
        callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
          payload[:context] == event_context
        end

        object.trigger_hook(:triggered)
      end
    end

    it 'triggers hook with custom namespace' do
      ActiveSupport::Notifications.subscribed(callback, 'triggered.my_namespace') do
        callback.expects(:call)

        object.trigger_hook(:triggered, namespace: :my_namespace)
      end
    end
  end
end
