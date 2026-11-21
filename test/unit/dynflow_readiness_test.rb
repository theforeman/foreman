require 'test_helper'
require 'foreman/dynflow_readiness'
require 'tmpdir'

class DynflowReadinessTest < ActiveSupport::TestCase
  class SidekiqEvents
    attr_reader :callbacks

    def initialize
      @callbacks = {}
    end

    def on(event, &block)
      callbacks[event] = block
    end
  end

  test 'tracks the Sidekiq lifecycle with a readiness file' do
    Dir.mktmpdir do |directory|
      path = File.join(directory, 'dynflow-ready')
      File.write(path, 'stale')
      events = SidekiqEvents.new

      Foreman::DynflowReadiness.install!(sidekiq: events, path: path)

      refute File.exist?(path)
      events.callbacks.fetch(:startup).call
      assert File.exist?(path)
      events.callbacks.fetch(:quiet).call
      refute File.exist?(path)
      events.callbacks.fetch(:startup).call
      events.callbacks.fetch(:shutdown).call
      refute File.exist?(path)
    end
  end

  test 'does not register hooks without a readiness path' do
    events = SidekiqEvents.new

    Foreman::DynflowReadiness.install!(sidekiq: events, path: nil)

    assert_empty events.callbacks
  end
end
