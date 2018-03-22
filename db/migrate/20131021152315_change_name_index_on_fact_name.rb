class ChangeNameIndexOnFactName < ActiveRecord::Migration[4.2]
  def up
    remove_index :fact_names, :column => :name, :unique => true
    options = if ActiveRecord::Base.connection.instance_values["config"][:adapter].grep(/mysql/).any?
                { :unique => true, :length => 254 }
              else
                { :unique => true }
              end
    add_index :fact_names, [:name, :type], options
  end

  def down
    remove_index :fact_names, [:name, :type]
    options = if ActiveRecord::Base.connection.instance_values["config"][:adapter].grep(/mysql/).any?
                { :unique => true, :length => 254 }
              else
                { :unique => true }
              end
    add_index :fact_names, :name, options
  end
end
