class FixHostAuditableType < ActiveRecord::Migration[4.2]
  def up
    Audit.where(:auditable_type => 'Host').update_all(:auditable_type => 'Host::Base')
  end

  def down
    Audit.where(:auditable_type => 'Host::Base').update_all(:auditable_type => 'Host')
  end
end
