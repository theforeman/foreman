class RemoveCounterCacheAudits < ActiveRecord::Migration[4.2]
  def up
    audits = Audit.reorder('').where(Audit.arel_table[:audited_changes].matches("%_count%"))
    audits.each do |audit|
      audit.audited_changes.except!("hosts_count", "hostgroups_count", "lookup_values_count", "lookup_keys_count", "global_class_params_count")
      if audit.audited_changes.empty?
        audit.delete
      else
        audit.save
      end
    end
  end

  def down
  end
end
