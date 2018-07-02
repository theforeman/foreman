class RemoveParamsValueLimit < ActiveRecord::Migration[5.1]
  def up
    change_column :parameters, :value, :text, :limit => nil
    change_column :lookup_values, :value, :text, :limit => nil
    change_column :lookup_keys, :default_value, :text, :limit => nil
  end

  def down
    # No need to revert, limit is only returned when converting to string in: 20120607074318_convert_params_to_text.rb
  end
end
