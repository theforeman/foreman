class RemoveAuditUserFk < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key(:audits, :users)
  end
end
