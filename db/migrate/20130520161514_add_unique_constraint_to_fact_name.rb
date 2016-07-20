class AddUniqueConstraintToFactName < ActiveRecord::Migration[4.2]
  def up
    remove_index(:fact_names, :column => :name) rescue nil
    options = if ActiveRecord::Base.connection.instance_values["config"][:adapter].grep(/mysql/).any?
                { :unique => true, :length => 254 }
              else
                { :unique => true }
              end
    add_index(:fact_names, :name, options)
  end

  def down
    remove_index(:fact_names, :column => :name)
  end
end
