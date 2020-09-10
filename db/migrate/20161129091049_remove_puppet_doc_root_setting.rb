class RemovePuppetDocRootSetting < ActiveRecord::Migration[4.2]
  def up
    Setting.where(:name => 'document_root', :category => 'Setting::Puppet').delete_all
  end
end
