class RemovePuppetDocRootSetting < ActiveRecord::Migration
  def up
    Setting.where(:name => 'document_root', :category => 'Setting::Puppet').delete_all
  end
end
