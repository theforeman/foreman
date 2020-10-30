class ConfigReportStatusCalculator
  # Converts a counters hash into a 64 bit integer (bit field). Required
  # arguments: counters (hash of counters) or bit_field (raw number for
  # reverse calculation), metrics (array of expected counter names in
  # the least significant bit order) and optional size (word size which
  # is calculated automatically to fit into 64 bit integer result).
  def initialize(options = {})
    @counters   = options[:counters]  || {}
    @raw_status = options[:bit_field] || 0
    @metrics    = options[:metrics] || ConfigReport::METRIC
    @size       = options[:size] || (64 / @metrics.size)
    @max_value  = (1 << @size) - 1
  end

  attr_reader :raw_status, :counters, :metrics, :size, :max_value

  # calculates the raw_status based on counters
  def calculate
    @raw_status = 0
    counters.each do |type, value|
      value = value.to_i # JSON does everything as strings
      value = @max_value if value > @max_value
      @raw_status |= value << (@size * metrics.index(type.to_s))
    end
    @raw_status &= 0xFFFFFFFFFFFFFFFF
  end

  # returns metrics (counters) based on raw_status (aka bit field)
  # to get status of specific metric, @see #status_of
  def status
    @status ||= begin
      calculate if raw_status == 0
      counters = Hash.new(0)
      metrics.each do |m|
        counters[m] = (raw_status || 0) >> (@size * metrics.index(m)) & @max_value
      end
      counters
    end
  end

  def status_of(counter)
    raise(Foreman::Exception.new(N_("invalid type %s"), counter)) unless metrics.include?(counter)
    status[counter]
  end

  def status_as_text_of(counter)
    result = status_of(counter)
    if result >= @max_value
      "#{result}+"
    else
      result.to_s
    end
  end

  # returns true if total error metrics are > 0
  def error?
    status_of('failed') + status_of('failed_restarts') > 0
  end

  # returns true if total action metrics are > 0
  def changes?
    status_of('applied') + status_of('restarted') > 0
  end

  # returns true if there are any changes pending
  def pending?
    status_of('pending') > 0
  end

  ConfigReport::METRIC.each do |method|
    define_method method do
      status_of(method)
    end

    define_method "#{method}_s".to_sym do
      status_as_text_of(method)
    end
  end
end
