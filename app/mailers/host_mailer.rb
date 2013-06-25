class HostMailer < ActionMailer::Base
  helper :reports

  default :content_type => "text/html", :from => Setting[:email_reply_address] || "noreply@foreman.exmaple.org"
  # sends out a summary email of hosts and their metrics (e.g. how many changes failures etc).


  def summary(options = {})
    # currently we send to all registered users or to the administrator (if LDAP is disabled).
    # TODO add support to host / group based emails.

    # options our host list if required
    filter = []

    if (@url = Setting[:foreman_url]).empty?
      raise ::Foreman::Exception.new N_("':foreman_url:' entry in Foreman configuration file, see http://theforeman.org/projects/foreman/wiki/Mail_Notifications")
    end

    if options[:env]
      hosts = envhosts = options[:env].hosts
      raise (_("unable to find any hosts for puppet environment=%s") % env) if envhosts.size == 0
      filter << "Environment=#{options[:env].name}"
    end
    name,value = options[:factname],options[:factvalue]
    if name and value
      facthosts = Host.search_for("facts.#{name}=#{value}")
      raise (_("unable to find any hosts with the fact name=%{name} and value=%{value}") % { :name => name, :value => value }) if facthosts.empty?
      filter << "Fact #{name}=#{value}"
      # if environment and facts are defined together, we use a merge of both
      hosts = envhosts.empty? ? facthosts : envhosts & facthosts
    end

    if hosts.empty?
      # print out an error if we couldn't find any hosts that match our request
      raise ::Foreman::Exception.new(N_("unable to find any hosts that match your request")) if options[:env] or options[:factname]
      # we didnt define a filter, use all hosts instead
      hosts = Host::Managed
    end
    email = options[:email] || Setting[:administrator]
    raise ::Foreman::Exception.new(N_("unable to find recipients")) if email.empty?
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
    subject = _("Summary Puppet report from Foreman - F:%{failed} R:%{restarted} S:%{skipped} A:%{applied} FR:%{failed_restarts} T:%{total}") % {
      :failed => total_metrics["failed"],
      :restarted => total_metrics["restarted"],
      :skipped => total_metrics["skipped"],
      :applied => total_metrics["applied"],
      :failed_restarts => total_metrics["failed_restarts"],
      :total => total_metrics["total"]
    }
    @hosts = host_data
    @timerange = time
    @out_of_sync = hosts.out_of_sync
    @disabled = hosts.alerts_disabled
    @filter = filter
    mail(:to => email, :subject => subject)
  end

  def error_state(report)
    host = report.host
    email = host.owner.recipients if SETTINGS[:login] and not host.owner.nil?
    email = Setting[:administrator]   if email.empty?
    raise ::Foreman::Exception.new(N_("unable to find recipients")) if email.empty?
    @report = report
    @host = host
    mail(:to => email, :subject => (_("Puppet error on %s") % host.to_label))
  end
end
