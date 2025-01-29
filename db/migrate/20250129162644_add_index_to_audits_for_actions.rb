class AddIndexToAuditsForActions < ActiveRecord::Migration[7.0]
  def change
    add_index :audits, [:auditable_type, :auditable_id, :action, :created_at],
      name: 'index_audits_on_auditable_action_created_at'
  end
end
