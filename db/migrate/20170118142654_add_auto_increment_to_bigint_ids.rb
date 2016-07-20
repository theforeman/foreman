class AddAutoIncrementToBigintIds < ActiveRecord::Migration[4.2]
  def self.up
    if ['mysql', 'mysql2'].include? ActiveRecord::Base.connection.instance_values['config'][:adapter]
      change_column :logs, :id, 'SERIAL'
      change_column :reports, :id, 'SERIAL'
      change_column :fact_values, :id, 'SERIAL'
    end
  end
  def self.down
    if ['mysql', 'mysql2'].include? ActiveRecord::Base.connection.instance_values['config'][:adapter]
      change_column :logs, :id, :bigint
      change_column :reports, :id, :bigint
      change_column :fact_values, :id, :bigint
    end
  end
end
