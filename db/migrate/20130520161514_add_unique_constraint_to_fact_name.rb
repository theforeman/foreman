class AddUniqueConstraintToFactName < ActiveRecord::Migration
  def self.up
    remove_index(:fact_names, :column => :name) rescue nil
    options = ActiveRecord::Base.connection.instance_values["config"][:adapter].grep(/mysql/).any? ?
      { :unique => true, :length => 254 } :
      { :unique => true }
    add_index(:fact_names, :name, options)
  end

  def self.down
    remove_index(:fact_names, :column => :name)
  end
end
