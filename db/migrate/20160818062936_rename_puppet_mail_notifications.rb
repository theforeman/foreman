class RenamePuppetMailNotifications < ActiveRecord::Migration[4.2]
  # We have to load this class in the migration so that existing mail
  # notifications of 'type=PuppetError' can load
  class ::PuppetError < ConfigManagementError
  end

  def up
    MailNotification.where(:name => 'puppet_summary').
      update_all(:name => 'config_summary')
    MailNotification.where(:name => 'puppet_error_state').
      update_all(:name => 'config_error_state', :type => ConfigManagementError)
  end

  def down
    MailNotification.where(:name => 'config_summary').
      update_all(:name => 'puppet_summary')
    MailNotification.where(:name => 'config_error_state').
      update_all(:name => 'puppet_error_state', :type => PuppetError)
  end
end
