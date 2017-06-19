class ChangeIdValueRange < ActiveRecord::Migration
  def self.up
    if %w[mysql mysql2 postgresql].include? ActiveRecord::Base.connection.instance_values['config'][:adapter]
      change_column :logs, :id, :bigint
      change_column :reports, :id, :bigint
      change_column :fact_values, :id, :bigint
    end
  end
  def self.down
    if %w[mysql mysql2 postgresql].include? ActiveRecord::Base.connection.instance_values['config'][:adapter]
      change_column :logs, :id, :int
      change_column :reports, :id, :int
      change_column :fact_values, :id, :int
    end
  end
end
