require 'uri'

class HostMailer < ApplicationMailer
  helper :reports

  # sends out a summary email of hosts and their metrics (e.g. how many changes failures etc).
  def summary(options = {})
    raise ::Foreman::Exception.new(N_("Must specify a valid user with email enabled")) unless (user = User.find(options[:user]))
    hosts = User.as user do
      Host::Managed.authorized_as(user, :view_hosts, Host)
    end
    time = options[:time] || 1.day.ago
    host_data = ConfigReport.summarise(time, hosts.all).sort

    total_metrics = load_metrics(host_data)
    total = 0
    total_metrics.values.each { |v| total += v }

    @hosts = host_data
    @timerange = time
    @out_of_sync = hosts.out_of_sync.sort
    @disabled = hosts.alerts_disabled.sort

    set_locale_for(user) do
      subject = _("Configuration Management Summary Report - F:%{failed} R:%{restarted} S:%{skipped} A:%{applied} FR:%{failed_restarts} T:%{total}") % {
        :failed => total_metrics["failed"],
        :restarted => total_metrics["restarted"],
        :skipped => total_metrics["skipped"],
        :applied => total_metrics["applied"],
        :failed_restarts => total_metrics["failed_restarts"],
        :total => total,
      }

      mail(:to => user.mail, :subject => subject) do |format|
        format.html { render :layout => 'application_mailer' }
      end
    end
  end

  def error_state(report, options = {})
    @report = report
    @host = @report.host
    set_locale_for(options[:user]) do
      mail(:to => options[:user].mail, :subject => (_("Configuration Management Error on %s") % @host)) do |format|
        format.html { render :layout => 'application_mailer' }
      end
    end
  end

  def host_built(host, options = {})
    @host = host

    set_locale_for(options[:user]) do
      mail(:to => options[:user].mail, :subject => (_("Host %s is built") % @host)) do |format|
        format.html { render :layout => 'application_mailer' }
        format.text
      end
    end
  end

  private

  def load_metrics(host_data)
    total_metrics = {"failed" => 0, "restarted" => 0, "skipped" => 0, "applied" => 0, "failed_restarts" => 0}

    host_data.flatten.delete_if { |x| true unless x.is_a?(Hash) }.each do |data_hash|
      total_metrics["failed"]          += data_hash[:metrics]["failed"]
      total_metrics["restarted"]       += data_hash[:metrics]["restarted"]
      total_metrics["skipped"]         += data_hash[:metrics]["skipped"]
      total_metrics["applied"]         += data_hash[:metrics]["applied"]
      total_metrics["failed_restarts"] += data_hash[:metrics]["failed_restarts"]
    end

    total_metrics
  end
end
