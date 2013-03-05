class HostMailer < ActionMailer::Base
  helper :reports
  # sends out a summary email of hosts and their metrics (e.g. how many changes failures etc).


  def summary(options = {})
    # currently we send to all registered users or to the administrator (if LDAP is disabled).
    # TODO add support to host / group based emails.

    # options our host list if required
    filter = []

    if (@url = Setting[:foreman_url]).empty?
      raise ":foreman_url: entry in Foreman configuration file, see http://www.theforeman.org/manuals/1.1/index.html#3.5.4PuppetReports"
    end

    if options[:env]
      hosts = envhosts = options[:env].hosts
      raise "unable to find any hosts for puppet environment=#{env}" if envhosts.size == 0
      filter << "Environment=#{options[:env].name}"
    end
    name,value = options[:factname],options[:factvalue]
    if name and value
      facthosts = Host.with_fact(name,value)
      raise "unable to find any hosts with the fact name=#{name} and value=#{value}" if facthosts.empty?
      filter << "Fact #{name}=#{value}"
      # if environment and facts are defined together, we use a merge of both
      hosts = envhosts.empty? ? facthosts : envhosts & facthosts
    end

    if hosts.empty?
      # print out an error if we couldn't find any hosts that match our request
      raise "unable to find any hosts that match your request" if options[:env] or options[:factname]
      # we didnt define a filter, use all hosts instead
      hosts = "Host::Managed"
    end
    email = options[:email] || Setting[:administrator]
    raise "unable to find recipients" if email.empty?
    recipients email
    from Setting["email_reply_address"]
    sent_on Time.now
    time = options[:time] || 1.day.ago
    host_data = Report.summarise(time, hosts.all).sort
    total_metrics = {"failed"=>0, "restarted"=>0, "skipped"=>0, "applied"=>0, "failed_restarts"=>0}
    host_data.flatten.delete_if { |x| true unless x.is_a?(Hash) }.each do |data_hash|
      total_metrics["failed"]          += data_hash[:metrics]["failed"]
      total_metrics["restarted"]       += data_hash[:metrics]["restarted"]
      total_metrics["skipped"]         += data_hash[:metrics]["skipped"]
      total_metrics["applied"]         += data_hash[:metrics]["applied"]
      total_metrics["failed_restarts"] += data_hash[:metrics]["failed_restarts"]
    end
    total = 0 ; total_metrics.values.each { |v| total += v }
    subject "Summary Puppet report from Foreman - F:#{total_metrics["failed"]} R:#{total_metrics["restarted"]} S:#{total_metrics["skipped"]} A:#{total_metrics["applied"]} FR:#{total_metrics["failed_restarts"]} T:#{total}"
    content_type "text/html"
    @hosts = host_data
    @timerange = time
    @out_of_sync = hosts.out_of_sync
    @disabled = hosts.alerts_disabled
    @filter = filter
  end

  def error_state(report)
    host = report.host
    email = host.owner.recipients if SETTINGS[:login] and not host.owner.nil?
    email = Setting[:administrator]   if email.empty?
    raise "unable to find recipients" if email.empty?
    recipients email
    from Setting["email_reply_address"]
    subject "Puppet error on #{host.to_label}"
    sent_on Time.now
    content_type "text/html"
    @report = report
    @host = host
  end
end
