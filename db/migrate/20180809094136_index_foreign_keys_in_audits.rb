class IndexForeignKeysInAudits < ActiveRecord::Migration[5.1]
  def change
    add_index :audits, :auditable_id
  end
end
