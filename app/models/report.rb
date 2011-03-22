class Report < ActiveRecord::Base
  include Authorization
  belongs_to :host
  has_many :messages, :through => :logs, :dependent => :destroy
  has_many :sources, :through => :logs, :dependent => :destroy
  has_many :logs, :dependent => :destroy
  validates_presence_of :host_id, :reported_at, :status
  validates_uniqueness_of :reported_at, :scope => :host_id

  METRIC = %w[applied restarted failed failed_restarts skipped]
  BIT_NUM = 6
  MAX = (1 << BIT_NUM) -1 # maximum value per metric

  # search for a metric - e.g.:
  # Report.with("failed") --> all reports which have a failed counter > 0
  # Report.with("failed",20) --> all reports which have a failed counter > 20
  named_scope :with, lambda { |*arg| { :conditions =>
    "(status >> #{BIT_NUM*METRIC.index(arg[0])} & #{MAX}) > #{arg[1] || 0}"}
  }

  # returns recent reports
  named_scope :recent, lambda { |*args| {:conditions => ["reported_at > ?", (args.first || 1.day.ago)]} }

  # with_changes
  named_scope :interesting, {:conditions => "status != 0"}

  # a method that save the report values (e.g. values from METRIC)
  # it is not supported to edit status values after it has been written once.
  def status=(st)
    s = st if st.is_a?(Integer)
    s = Report.calc_status st if st.is_a?(Hash)
    write_attribute(:status,s) unless s.nil?
  end

  #returns metrics
  #when no metric type is specific returns hash with all values
  #passing a METRIC member will return its value
  def status(type = nil)
    raise "invalid type #{type}" if type and not METRIC.include?(type)
    h = {}
    (type || METRIC).each do |m|
      h[m] = (read_attribute(:status) || 0) >> (BIT_NUM*METRIC.index(m)) & MAX
    end
    return type.nil? ? h : h[type]
  end

  # extracts serialized metrics and keep them as a hash_with_indifferent_access
  def metrics
    YAML.load(read_attribute(:metrics)).with_indifferent_access
  end

  # serialize metrics as YAML
  def metrics= m
    write_attribute(:metrics,m.to_yaml) unless m.nil?
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

  def to_label
    "#{host.name} / #{reported_at.to_s}"
  end

  def config_retrieval
    metrics[:time][:config_retrieval].round_with_precision(2) rescue "N/A"
  end

  def runtime
    (metrics[:time][:total] || metrics[:time].values.sum).round_with_precision(2) rescue "N/A"
  end

  #imports a YAML report into database
  def self.import(yaml)
    report = YAML.load(yaml)
    raise "Invalid report" unless report.is_a?(Puppet::Transaction::Report)
    logger.info "processing report for #{report.host}"
    begin
      host = Host.find_or_create_by_name report.host

      # parse report metrics
      raise "Invalid report: can't find metrics information for #{report.host} at #{report.id}" if report.metrics.nil?

      # Is this a pre 2.6.x report format?
      @post265 = report.instance_variables.include?("@report_format")
      @pre26   = !report.instance_variables.include?("@resource_statuses")

      # convert report status to bit field
      st = calc_status(metrics_to_hash(report))

      # update host record
      # we update our host record, so we wont need to lookup the report information just to display the host list / info
      # save our report time
      host.last_report = report.time.utc if host.last_report.nil? or host.last_report.utc < report.time.utc

      # we save the raw bit status value in our host too.
      host.puppet_status = st

      # we save the host without validation for two reasons:
      # 1. It might be auto imported, therefore might not be valid (e.g. missing partition table etc)
      # 2. We want this to be fast and light on the db.
      # at this point, the report is important, not as much of the host
      host.save_with_validation(false)

      # and save our report
      r = self.create!(:host => host, :reported_at => report.time.utc, :status => st, :metrics => self.m2h(report.metrics))
      # Store all Puppet message logs
      r.import_log_messages report
      # if we are using storeconfigs then we already have the facts
      # so we can refresh foreman internal fields accordingly
      host.populateFieldsFromFacts if SETTINGS[:using_storeconfigs]
      r.inspect_report
      return r
    rescue Exception => e
      logger.warn "Failed to process report for #{report.host} due to:#{e}"
      false
    end
  end

  # returns a hash of hosts and their recent reports metric counts which have values
  # e.g. non zero metrics.
  # first argument is time range, everything afterwards is a host list.
  # TODO: improve SQL query (so its not N+1 queries)
  def self.summarise(time = 1.day.ago, *hosts)
    list = {}
    raise "invalid host list" unless hosts
    hosts.flatten.each do |host|
      # set default of 0 per metric
      metrics = {}
      METRIC.each {|m| metrics[m] = 0 }
      host.reports.recent(time).all(:select => "status").each do |r|
        metrics.each_key do |m|
          metrics[m] += r.status(m)
        end
      end
      list[host.name] = {:metrics => metrics, :id => host.id} if metrics.values.sum > 0
    end
    return list
  end

  # add sort by report time
  def <=>(other)
    self.created_at <=> other.created_at
  end

  # Expire reports based on time and status
  # Defaults to expire reports older than a week regardless of the status
  def self.expire(conditions = {})
    timerange = conditions[:timerange] || 1.week
    status = conditions[:status]
    cond = "created_at < \'#{(Time.now.utc - timerange).to_formatted_s(:db)}\'"
    cond += " and status = #{status}" unless status.nil?
    # delete the reports, must use destroy_all vs. delete_all because of assoicated logs and METRIC
    count = Report.destroy_all(cond)
    logger.info Time.now.to_s + ": Expired #{count} Reports"
    return count
  end

  def self.count_puppet_runs(interval = nil)
    interval ||= SETTINGS[:puppet_interval] / 10
    counter = []
    now=Time.now.utc
    (1..(SETTINGS[:puppet_interval] / interval)).each do
      ago = now - interval.minutes
      counter << [ now.getlocal, Report.count(:all, :conditions => {:reported_at => ago..(now-1.second)})]
      now = ago
    end
    counter
  end

  def import_log_messages report
    report.logs.each do |r|
      # skiping debug messages, we dont want them in our db
      next if r.level == :debug
      message = Message.find_or_create_by_value r.message
      source  = Source.find_or_create_by_value r.source
      log = Log.create :message_id => message.id, :source_id => source.id, :report_id => self.id, :level => r.level
      log.errors.empty?
    end
  end

  def inspect_report
    if error?
      # found a report with errors
      # notify via email IF enabled is set to true
      logger.warn "#{report.host} is disabled - skipping." and return if host.disabled?

      logger.debug "error detected, checking if we need to send an email alert"
      HostMailer.deliver_error_state(self) if SETTINGS[:failed_report_email_notification]
      # add here more actions - e.g. snmp alert etc
    end
  rescue => e
    logger.warn "failed to send failure email notification: #{e}"
  end

  private

  # Converts metrics form Puppet report into a hash
  # this hash is required by the calc_status method
  def self.metrics_to_hash(report)
    report_status = {}
    metrics = report.metrics.with_indifferent_access

    # find our metric values
    METRIC.each do |m|
      if @pre26
        report_status[m] = metrics["resources"][m.to_sym]
      else
        h=translate_metrics_to26(m)
        mv = metrics[h[:type]]
        report_status[m] = mv[h[:name].to_sym] + mv[h[:name].to_s] rescue nil
      end
      report_status[m] ||= 0
    end

    # special fix for false warning about skips
    # sometimes there are skip values, but there are no error messages, we ignore them.
    if report_status["skipped"] > 0 and ((report_status.values.sum) - report_status["skipped"] == report.logs.size)
      report_status["skipped"] = 0
    end
    # fix for reports that contain no metrics (i.e. failed catalog)
    if @post265 and report.respond_to?(:status) and report.status == "failed"
      report_status["failed"] += 1
    end
    return report_status
  end


  # return all metrics as a hash
  def self.m2h metrics
    h = {}
    metrics.each do |title, mtype|
      h[mtype.name] ||= {}
      mtype.values.each{|m| h[mtype.name].merge!({m[0] => m[2]})}
    end
    return h
  end


  # converts a hash into a bit field
  # expects a metrics_to_hash kind of hash
  def self.calc_status (hash = {})
    st = 0
    hash.each do |type, value|
      value = MAX if value > MAX # we store up to 2^BIT_NUM -1 values as we want to use only BIT_NUM bits.
      st |= value << (BIT_NUM*METRIC.index(type))
    end
    return st
  end

  def validate_meteric (type, name)
    log.metrics[type][name].to_f
  rescue Exception => e
    logger.warn "failed to process report due to #{e}"
    nil
  end

  # The metrics layout has changed in Puppet 2.6.x release,
  # this method attempts to align the bit value metrics and the new name scheme in 2.6.x
  # returns a hash of { :type => "metric type", :name => "metric_name"}
  def self.translate_metrics_to26 metric
    case metric
    when "applied"
      if @post265
        { :type => "changes", :name => "total"}
      else
        { :type => "total", :name => :changes}
      end
    else
      { :type => "resources", :name => metric}
    end
  end

  def enforce_permissions operation
    # No one can edit a report
    return false if operation == "edit"

    # Anyone can create a report
    return true if operation == "create"
    return true if operation == "destroy" and User.current.allowed_to?(:destroy_reports)

    errors.add_to_base "You do not have permission to #{operation} this report"
    false
  end
end
