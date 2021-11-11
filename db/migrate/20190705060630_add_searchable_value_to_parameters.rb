class AddSearchableValueToParameters < ActiveRecord::Migration[5.2]
  def change
    add_column :parameters, :searchable_value, :text
  end
end
