class RemoveTotalHostsAudits < ActiveRecord::Migration
  def up
    Audit.where(:auditable_type=> 'Puppetclass').where(Audit.arel_table[:audited_changes].matches("%total_hosts%")).delete_all
  end

  def down
  end
end
