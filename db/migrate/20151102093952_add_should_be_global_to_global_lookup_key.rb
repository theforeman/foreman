class AddShouldBeGlobalToGlobalLookupKey < ActiveRecord::Migration
  def change
    add_column :lookup_keys, :should_be_global, :boolean
  end
end
