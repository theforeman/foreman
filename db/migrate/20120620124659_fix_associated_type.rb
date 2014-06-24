class FixAssociatedType < ActiveRecord::Migration
  def self.up
    execute "UPDATE audits SET associated_type='Host' WHERE associated_type='Puppet::Rails::Host'"
  end

  def self.down
    execute "UPDATE audits SET associated_type='Puppet::Rails::Host' WHERE associated_type='Host'"
  end
end
