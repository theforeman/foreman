class RestrictSendmailLocation < ActiveRecord::Migration[6.0]
  def up
    Setting.without_auditing do
      existing = Setting.find_by_name("sendmail_location")
      if existing && !Setting::Email::SENDMAIL_LOCATIONS.include?(existing.value)
        say "Sendmail location '#{existing.value}' not allowed, resetting to default"
        existing.value = nil
        existing.save!
      end
    end
  end
end
