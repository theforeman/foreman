class AddClonedFromToTemplates < ActiveRecord::Migration[6.1]
  def change
    add_reference(:templates, :cloned_from, foreign_key: { to_table: :templates, on_delete: :nullify })
  end
end
