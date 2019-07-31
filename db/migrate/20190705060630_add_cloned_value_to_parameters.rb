class AddClonedValueToParameters < ActiveRecord::Migration[5.2]
  def change
    add_column :parameters, :cloned_value, :text

    if column_exists?(:parameters, :cloned_value)
      Parameter.unscoped.find_each do |param|
        param.save
      end
    end
  end
end
