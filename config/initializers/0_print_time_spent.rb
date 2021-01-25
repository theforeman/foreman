# frozen_string_literal: true

# This class is taken from https://github.com/nevir/Bumbler which
# depends on bundler. But for RPM environment, Foreman does not
# use bundler (but bundler_ext stub). The gem won't load in that
# environment.
module ForemanInitializers
  @slow_threshold = 100.0
  @slow_items = {}

  class << self
    attr_writer :slow_threshold
    attr_reader :slow_items

    def benchmark(key)
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = yield
      time = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000 # ms
      @slow_items[key] = time if time > @slow_threshold
      result
    end

    def print_slow_items
      if slow_items.any?
        Rails.logger.debug "Slow initializers:"
        slow_items.sort_by { |k, v| v }.each do |name, time|
          Rails.logger.debug format('  %s  %s', ('%.2f' % time).rjust(8), name)
        end
      end
      self
    end
  end
end

Rails::Engine.prepend(Module.new do
  def load(file, *)
    initializer = file.sub(Rails.root.to_s, ".")
    ForemanInitializers.benchmark(initializer) { super }
  end
end)

Rails::Initializable::Initializer.prepend(Module.new do
  def run(*)
    name = (@name.is_a?(Symbol) ? @name.inspect : @name)
    ForemanInitializers.benchmark(name) { super }
  end
end)
