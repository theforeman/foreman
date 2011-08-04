module ReportCommon
  METRIC = %w[applied restarted failed failed_restarts skipped]
  BIT_NUM = 6
  MAX = (1 << BIT_NUM) -1 # maximum value per metric

  def self.included(base)
    base.class_eval do
      # search for a metric - e.g.:
      # Report.with("failed") --> all reports which have a failed counter > 0
      # Report.with("failed",20) --> all reports which have a failed counter > 20
      named_scope :with, lambda { |*arg| {
        :conditions => "(#{report_status} >> #{BIT_NUM*METRIC.index(arg[0])} & #{MAX}) > #{arg[1] || 0}"}
      }
    end
  end

  # generate dynamically methods for all metrics
  # e.g. Report.last.applied
  METRIC.each do |method|
    define_method method do
      status method
    end
  end

  # returns true if total error metrics are > 0
  def error?
    %w[failed failed_restarts].sum {|f| status f} > 0
  end

  # returns true if total action metrics are > 0
  def changes?
    %w[applied restarted].sum {|f| status f} > 0
  end

  #returns metrics
  #when no metric type is specific returns hash with all values
  #passing a METRIC member will return its value
  def status(type = nil)
    raise "invalid type #{type}" if type and not METRIC.include?(type)
    h = {}
    (type || METRIC).each do |m|
      h[m] = (read_attribute(self.class.report_status) || 0) >> (BIT_NUM*METRIC.index(m)) & MAX
    end
    return type.nil? ? h : h[type]
  end

end
