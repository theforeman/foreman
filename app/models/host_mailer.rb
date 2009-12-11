class HostMailer < ActionMailer::Base
  # sends out a summary email of hosts and their metrics (e.g. how many changes failures etc).
  def summary(time = 1.day.ago,*hosts)
    # currently we send to all registered users or to the administrator (if LDAP is disabled).
    # TODO add support to host / group based emails.
    email = SETTINGS[:administrator] || User.all(:select => :mail).map(&:mail)
    raise "unable to find recipients" if email.empty?
    recipients email
    from "Foreman-noreply"
    subject "Summary Puppet report from Foreman"
    sent_on Time.now
    body[:hosts] = Report.summarise(time, hosts).sort
    body[:url] = SETTINGS[:foreman_url]
    body[:timerange] = time
    body[:out_of_sync] = Host.out_of_sync.all(:order => "name asc")
  end

end
