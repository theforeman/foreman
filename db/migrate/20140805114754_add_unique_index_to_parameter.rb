class AddUniqueIndexToParameter < ActiveRecord::Migration[4.2]
  def up
    found = []
    Parameter.find_each do |param|
      new_param = {:name => param.name, :type => param.type, :reference_id => param.reference_id}
      if found.include?(new_param)
        param.destroy
      else
        found << new_param
      end
    end

    add_index :parameters, [:type, :reference_id, :name], :unique => true
  end

  def down
    # previous version, prior to #8366 and 20141112165600_add_type_to_parameter_index
    remove_index :parameters, :column => [:reference_id, :name] if index_exists? :parameters, [:reference_id, :name], :unique => true
    remove_index :parameters, :column => [:type, :reference_id, :name] if index_exists? :parameters, [:type, :reference_id, :name], :unique => true
  end
end
