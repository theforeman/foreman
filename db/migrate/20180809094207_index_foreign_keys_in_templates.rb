class IndexForeignKeysInTemplates < ActiveRecord::Migration[5.1]
  def change
    add_index :templates, :template_kind_id
  end
end
