class ReportStatusCalculator
  # converts a counters hash into a bit field
  # expects a metrics_to_hash kind of counters
  # see the report_processor for the implementation
  def initialize(options = {})
    @counters   = options[:counters]  || {}
    @raw_status = options[:bit_field] || 0
  end

  # calculates the raw_status based on counters
  def calculate
    @raw_status = 0
    counters.each do |type, value|
      value = value.to_i                         # JSON does everything as strings
      value = Report::MAX if value > Report::MAX # we store up to 2^BIT_NUM -1 values as we want to use only BIT_NUM bits.
      @raw_status |= value << (Report::BIT_NUM * Report::METRIC.index(type))
    end
    raw_status
  end

  # returns metrics (counters) based on raw_status (aka bit field)
  # to get status of specific metric, @see #status_of
  def status
    @status ||= begin
      calculate if raw_status == 0
      counters = Hash.new(0)
      Report::METRIC.each do |m|
        counters[m] = (raw_status || 0) >> (Report::BIT_NUM * Report::METRIC.index(m)) & Report::MAX
      end
      counters
    end
  end

  def status_of(counter)
    raise(Foreman::Exception.new(N_("invalid type %s"), counter)) unless Report::METRIC.include?(counter)
    status[counter]
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

  # generate dynamically methods for all metrics
  # e.g. applied failed ...
  Report::METRIC.each do |method|
    define_method method do
      status_of(method)
    end
  end

  private

  attr_reader :raw_status, :counters
end
