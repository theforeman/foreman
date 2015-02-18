require 'facter'
class AddOwnerToHosts < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  class Host < ActiveRecord::Base; end

  def self.up
    add_column :hosts, :owner_id,   :integer
    add_column :hosts, :owner_type, :string

    Host.reset_column_information

    email = SETTINGS[:administrator] || "root@#{Facter.value(:domain)}"
    owner = User.find_by_mail email
    owner ||= User.where(:admin => true).first
    unless owner.nil? or owner.id.nil?
      say "setting default owner for all hosts"
      Host.update_all("owner_id = '#{owner.id}'")
    end
  end

  def self.down
    remove_column :hosts, :owner_type
    remove_column :hosts, :owner_id
  end
end
