class AddEnumTypeToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :enum_values, :string
  end
end
