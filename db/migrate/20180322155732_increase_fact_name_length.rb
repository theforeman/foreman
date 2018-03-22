class IncreaseFactNameLength < ActiveRecord::Migration[5.0]
  def up
    change_table :fact_names do |t|
      t.change :name, :string, :limit => 4096
      t.change :ancestry, :string, :limit => 4096
      t.change :short_name, :string, :limit => 4096
    end
  end

  def down
    change_table :fact_names do |t|
      t.change :name, :string, :limit => 255
      t.change :ancestry, :string, :limit => 255
      t.change :short_name, :string, :limit => 255
    end
  end
end
