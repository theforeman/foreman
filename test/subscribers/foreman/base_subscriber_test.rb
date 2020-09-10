require 'test_helper'

class BaseSubscriberTest < ActionView::TestCase
  subject { ::Foreman::BaseSubscriber }

  let(:event_name) { :my_event }
  let(:started) { Time.parse('17.12.2019 12:00') }
  let(:finished) { Time.parse('17.12.2019 12:01') }
  let(:unique_id) { 'b22021c7711ecaf4ed61' }
  let(:payload) { { id: 1 } }
  let(:args) { [event_name, started, finished, unique_id, payload] }
  let(:event) { ActiveSupport::Notifications::Event.new(*args) }

  test '.call' do
    assert_respond_to subject, 'call'

    subscriber = ActiveSupport::Notifications.subscribe event_name, subject

    subject.any_instance.expects(:call).with do |event|
      event.name == event_name && event.payload == payload
    end

    ActiveSupport::Notifications.instrument(event_name, payload)
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  test '#call' do
    assert_respond_to subject.new, 'call'

    assert_raise(NotImplementedError) do
      subject.new.call(event)
    end
  end
end
