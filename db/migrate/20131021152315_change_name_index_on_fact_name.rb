class ChangeNameIndexOnFactName < ActiveRecord::Migration
  def up
    remove_index :fact_names, :column => :name, :unique => true
    options = ActiveRecord::Base.connection.instance_values["config"][:adapter].grep(/mysql/).any? ?
        { :unique => true, :length => 254 } :
        { :unique => true }
    add_index :fact_names, [:name, :type], options
  end

  def down
    remove_index :fact_names, [:name, :type]
    options = ActiveRecord::Base.connection.instance_values["config"][:adapter].grep(/mysql/).any? ?
        { :unique => true, :length => 254 } :
        { :unique => true }
    add_index :fact_names, :name, options
  end
end
