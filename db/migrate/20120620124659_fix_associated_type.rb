class FixAssociatedType < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE audits SET associated_type='Host' WHERE associated_type='Puppet::Rails::Host'"
  end

  def down
    execute "UPDATE audits SET associated_type='Puppet::Rails::Host' WHERE associated_type='Host'"
  end
end
