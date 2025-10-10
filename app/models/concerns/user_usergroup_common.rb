module UserUsergroupCommon
  extend ActiveSupport::Concern

  included do
    after_destroy_commit :clear_host_owner_setting
  end

  def clear_host_owner_setting
    return unless Setting[:host_owner] == id_and_type
    setting = Foreman.settings.set_user_value('host_owner', '')
    setting.save
  end

  def ssh_authorized_keys
    ssh_keys.map(&:to_export)
  end
end
