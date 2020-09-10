class AddAncestryNameIndexOnFactName < ActiveRecord::Migration[4.2]
  def change
    add_index :fact_names, [:ancestry, :name]
  end
end
