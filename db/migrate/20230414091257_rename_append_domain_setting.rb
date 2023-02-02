class RenameAppendDomainSetting < ActiveRecord::Migration[6.1]
  def change
    Setting.find_by(name: 'append_domain_name_for_hosts')&.update_attribute(:name, 'display_fqdn_for_hosts')
  end
end
