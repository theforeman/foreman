class AddSearchableValueToParameters < ActiveRecord::Migration[5.2]
  def change
    add_column :parameters, :searchable_value, :text

    Parameter.unscoped.find_each do |param|
      param.update_columns(searchable_value: param.send(:set_searchable_value))
    end
  end
end
