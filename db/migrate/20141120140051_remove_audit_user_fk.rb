class RemoveAuditUserFk < ActiveRecord::Migration
  def change
    remove_foreign_key(:audits, :user)
  end
end
