class UpdateIgnoredInterfacesSettingDescription < ActiveRecord::Migration[6.0]
  def up
    setting = Setting.find_by(name: 'ignored_interface_identifiers')
    return unless setting

    setting.update(description: N_("Skip creating or updating host network interfaces objects with identifiers matching these values from incoming facts. You can use * wildcard to match identifiers with indexes e.g. macvtap*. The ignored interfaces raw facts will be still stored in the DB, see the 'Exclude pattern' setting for more details."))
  end
end
