class RestrictSendmailLocation < ActiveRecord::Migration[6.0]
  SENDMAIL_LOCATIONS = %w(/usr/sbin/sendmail /usr/bin/sendmail /usr/local/sbin/sendmail /usr/local/bin/sendmail)

  def up
    Setting.without_auditing do
      value = Setting.where(name: "sendmail_location").pick(:value)
      if value && !SENDMAIL_LOCATIONS.include?(value)
        say "Sendmail location '#{value}' not allowed, resetting to default"
        Setting.where(name: "sendmail_location").delete_all
      end
    end
  end
end
