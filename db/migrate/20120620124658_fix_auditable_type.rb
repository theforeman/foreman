class FixAuditableType < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE audits SET auditable_type='Host' WHERE auditable_type='Puppet::Rails::Host'"
  end

  def down
    execute "UPDATE audits SET auditable_type='Puppet::Rails::Host' WHERE auditable_type='Host'"
  end
end
