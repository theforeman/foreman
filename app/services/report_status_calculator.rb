class ReportStatusCalculator

  # converts a counters hash into a bit field
  # expects a metrics_to_hash kind of counters
  # see the report_processor for the implementation
  def initialize(options = {})
    @counters   = options[:counters]  || {}
    @raw_status = options[:bit_field] || 0
  end

  def calculate
    @raw_status = 0
    counters.each do |type, value|
      value = value.to_i                         # JSON does everything as strings
      value = Report::MAX if value > Report::MAX # we store up to 2^BIT_NUM -1 values as we want to use only BIT_NUM bits.
      @raw_status |= value << (Report::BIT_NUM * Report::METRIC.index(type))
    end
    raw_status
  end

  #returns metrics
  #when no metric type is specific returns hash with all values
  #passing a METRIC member will return its value
  def status(type = nil)
    calculate if raw_status == 0
    raise(Foreman::Exception(N_("invalid type %s") % type)) if type && !Report::METRIC.include?(type)
    counters = Hash.new(0)
    (type.is_a?(String) ? [type] : Report::METRIC).each do |m|
      counters[m] = (raw_status || 0) >> (Report::BIT_NUM * Report::METRIC.index(m)) & Report::MAX
    end
    type.nil? ? counters : counters[type]
  end

  private
  attr_reader :raw_status, :counters

end