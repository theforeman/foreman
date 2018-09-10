class ChangeDefaultPxeItems < ActiveRecord::Migration[5.2]
  def up
    Setting.without_auditing do
      ['default_pxe_item_global', 'default_pxe_item_local'].each do |name|
        setting = Setting.where(:name => name).first
        setting&.update_attribute(:default, '')
      end
    end
  end
end
