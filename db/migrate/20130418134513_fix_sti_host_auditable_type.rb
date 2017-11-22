class FixStiHostAuditableType < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE audits SET auditable_type='Host' WHERE auditable_type='Host::Base'"
  end

  def down
    # no way to reverse this
  end
end
