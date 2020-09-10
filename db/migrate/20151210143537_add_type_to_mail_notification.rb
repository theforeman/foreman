class AddTypeToMailNotification < ActiveRecord::Migration[4.2]
  def change
    add_column :mail_notifications, :type, :string, :limit => 255
    MailNotification.reset_column_information
    puppet_error = MailNotification.find_by_name('puppet_error_state')
    if puppet_error.present?
      puppet_error.type = 'PuppetError'
      puppet_error.save
    end
  end
end
