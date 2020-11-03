require 'test_helper'

class ObservableModelTest < ActiveSupport::TestCase
  describe '#set_hook' do
    let(:model) { model_class.create(name: 'My Model') }
    let(:model_class) do
      Class.new(ApplicationRecord) do
        include ::Foreman::ObservableModel

        def self.name
          'Model'
        end

        set_hook :model_updated, on: :update
        set_hook :model_updated_with_payload, on: :update, payload: { custom_payload: true }
        set_hook :model_updated_with_block, on: :update do |m|
          { id: m.id, block: true }
        end
        set_hook :model_info_updated, if: :saved_change_to_info?
      end
    end
    let(:callback) { -> {} }
    let(:event_context) { ::Logging.mdc.context.symbolize_keys.with_indifferent_access }

    test 'event subscription hooks are defined in the the Model class' do
      expected_event_subscription_hooks = [
        'model_updated.event.foreman',
        'model_updated_with_payload.event.foreman',
        'model_updated_with_block.event.foreman',
        'model_info_updated.event.foreman',
      ]

      assert_same_elements expected_event_subscription_hooks, model_class.event_subscription_hooks
    end

    test 'notify with event context' do
      ActiveSupport::Notifications.subscribed(callback, 'model_updated.event.foreman') do
        callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
          payload[:context] == event_context
        end

        model.update(name: 'New Name')
      end
    end

    test 'notify with default payload' do
      ActiveSupport::Notifications.subscribed(callback, 'model_updated.event.foreman') do
        callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
          payload[:object] == model
        end

        model.update(name: 'New Name')
      end
    end

    test 'notify with custom payload' do
      ActiveSupport::Notifications.subscribed(callback, 'model_updated_with_payload.event.foreman') do
        callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
          payload[:custom_payload] == true
        end

        model.update(name: 'New Name')
      end
    end

    test 'notify with block payload' do
      ActiveSupport::Notifications.subscribed(callback, 'model_updated_with_block.event.foreman') do
        callback.expects(:call).with do |name, _started, _finished, _unique_id, payload|
          payload[:id] == model.id && payload[:block] == true
        end

        model.update(name: 'New Name')
      end
    end

    test 'notify with if condition' do
      ActiveSupport::Notifications.subscribed(callback, 'model_info_updated.event.foreman') do
        callback.expects(:call).once

        model.update(name: 'New Name')
        model.update(info: 'New Info')
      end
    end

    describe '.set_crud_hooks' do
      let(:model_class) do
        Class.new(ApplicationRecord) do
          include ::Foreman::ObservableModel

          def self.name
            'Model'
          end

          set_crud_hooks :model
        end
      end

      let(:callback) { -> {} }

      test 'hooks are defined' do
        expected = [
          'model_created.event.foreman',
          'model_updated.event.foreman',
          'model_destroyed.event.foreman',
        ]

        assert_same_elements expected, model_class.event_subscription_hooks
      end

      describe 'model_created hook' do
        let(:model) { model_class.new(name: 'My Model') }

        test 'event is sent when model is created' do
          ActiveSupport::Notifications.subscribed(callback, 'model_created.event.foreman') do
            callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
              payload[:object] == model
            end

            model.save!
          end
        end
      end

      describe 'model_updated hook' do
        let(:model) { model_class.create(name: 'My Model') }

        test 'event is sent when model is updated' do
          ActiveSupport::Notifications.subscribed(callback, 'model_updated.event.foreman') do
            callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
              payload[:object] == model
            end

            model.update!(name: 'New Name')
          end
        end
      end

      describe 'model_destroyed hook' do
        let(:model) { model_class.create(name: 'My Model') }

        test 'event is sent when model is destroyed' do
          ActiveSupport::Notifications.subscribed(callback, 'model_destroyed.event.foreman') do
            callback.expects(:call).with do |_name, _started, _finished, _unique_id, payload|
              payload[:object] == model
            end

            model.destroy!
          end
        end
      end
    end
  end
end
