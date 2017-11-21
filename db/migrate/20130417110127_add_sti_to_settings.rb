class AddStiToSettings < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE settings set category='Setting::Auth' where category='Auth'"
    execute "UPDATE settings set category='Setting::General' where category='General'"
    execute "UPDATE settings set category='Setting::Puppet' where category='Puppet'"
    execute "UPDATE settings set category='Setting::Provisioning' where category='Provisioning'"
    add_index :settings, :category
  end

  def down
    execute "UPDATE settings set category='Auth' where category='Setting::Auth'"
    execute "UPDATE settings set category='General' where category='Setting::General'"
    execute "UPDATE settings set category='Puppet' where category='Setting::Puppet'"
    execute "UPDATE settings set category='Provisioning' where category='Setting::Provisioning'"
    remove_index :settings, :category
  end
end
