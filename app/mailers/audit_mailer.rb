class AuditMailer < ApplicationMailer
  helper :audits, :layout

  def summary(options = {})
    raise ::Foreman::Exception.new(N_("Must specify a user with email enabled")) unless (user=User.find(options[:user])) && user.mail_enabled?
    time = options[:time] ? %(time >= "#{options[:time]}") : 'time > yesterday'
    set_url
    @query   = options[:query].present? ? "#{options[:query]} and #{time}" : "#{time}"
    @count   = Audit.authorized_as(user, :view_audit_logs, Audit).search_for(@query).count
    @limit   = Setting[:entries_per_page] > @count ? @count : Setting[:entries_per_page]
    @audits  = Audit.authorized_as(user, :view_audit_logs, Audit).search_for(@query).limit(@limit)

    set_locale_for(user) do
      mail(:to => user.mail, :subject => _("Audit summary"))
    end
  end
end
