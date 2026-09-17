class RemoveSendmailSettings < ActiveRecord::Migration[7.0]
  def up
    Setting.where(name: ['sendmail_location', 'sendmail_arguments', 'delivery_method']).destroy_all
  end

  def down
  end
end
