class AddAncestryNameIndexOnFactName < ActiveRecord::Migration
  def change
    add_index :fact_names, [:ancestry, :name]
  end
end
