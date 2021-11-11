class ChangeIdValueRange < ActiveRecord::Migration[4.2]
  def self.up
    change_column :logs, :id, :bigint
    change_column :reports, :id, :bigint
    change_column :fact_values, :id, :bigint
  end

  def self.down
    change_column :logs, :id, :int
    change_column :reports, :id, :int
    change_column :fact_values, :id, :int
  end
end
