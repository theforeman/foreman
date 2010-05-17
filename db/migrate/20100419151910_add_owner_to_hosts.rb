class AddOwnerToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :owner_id,   :integer
    add_column :hosts, :owner_type, :string

    Host.reset_column_information

    updated = []
    email = SETTINGS[:administrator] || "root@" + Facter.domain
    owner = User.find_by_mail email
    owner ||= User.find_or_create_by_login(:login => "admin", :admin => true, :firstname => "Admin", :lastname => "User", :mail => email)
    say "setting default owner for all hosts"
    Host.update_all("owner_id = '#{owner.id}'")
  end

  def self.down
    remove_column :hosts, :owner_type
    remove_column :hosts, :owner_id
  end
end
