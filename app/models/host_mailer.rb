class HostMailer < ActionMailer::Base
  # sends out a summary email of hosts and their metrics (e.g. how many changes failures etc).
  def summary(options = {})
    # currently we send to all registered users or to the administrator (if LDAP is disabled).
    # TODO add support to host / group based emails.

    # options our host list if required
    filter = []
    conditions = {:select => "hosts.name, hosts.id, hosts.last_report", :order => "name asc"}
    if options[:env]
      hosts = envhosts = options[:env].hosts(conditions)
      raise "unable to find any hosts for puppet environment=#{env}" if envhosts.size == 0
      filter << "Environment=#{options[:env].name}"
    end
    name,value = options[:factname],options[:factvalue]
    if name and value
      facthosts = Host.with_fact(name,value).all(conditions)
      raise "unable to find any hosts with the fact name=#{name} and value=#{value}" if facthosts.empty?
      filter << "Fact #{name}=#{value}"
      # if environment and facts are defined together, we use a merge of both
      hosts = envhosts.empty? ? facthosts : envhosts & facthosts
    end

    if hosts.empty?
      # print out an error if we couldn't find any hosts that match our request
      raise "unable to find any hosts that match your request" if options[:env] or options[:factname]
      # we didnt define a filter, use all hosts instead
      hosts=Host.all(conditions)
    end
    email = options[:email] || SETTINGS[:administrator] || User.all(:select => :mail).map(&:mail)
    raise "unable to find recipients" if email.empty?
    recipients email
    from "Foreman-noreply"
    subject "Summary Puppet report from Foreman"
    sent_on Time.now
    time = options[:time] || 1.day.ago
    body[:hosts] = Report.summarise(time, hosts).sort
    body[:url] = SETTINGS[:foreman_url]
    body[:timerange] = time
    body[:out_of_sync] = hosts.collect{|h| h if h.no_report}.compact
    body[:filter] = filter
  end

  def error_state(report)
    host = report.host
    email = SETTINGS[:administrator]
    raise "unable to find recipients" if email.empty?
    recipients email
    from "Foreman-noreply"
    subject "Puppet error on #{host.to_label}"
    sent_on Time.now
    body[:report] = report
    body[:host] = host
  end
end
