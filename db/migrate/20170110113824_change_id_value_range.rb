class ChangeIdValueRange < ActiveRecord::Migration[4.2]
  def self.up
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      change_column :logs, :id, :bigint
      change_column :reports, :id, :bigint
      change_column :fact_values, :id, :bigint
    end
  end

  def self.down
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      change_column :logs, :id, :int
      change_column :reports, :id, :int
      change_column :fact_values, :id, :int
    end
  end
end
