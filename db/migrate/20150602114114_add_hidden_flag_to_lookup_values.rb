class AddHiddenFlagToLookupValues < ActiveRecord::Migration
  def change
    add_column :lookup_keys, :hidden, :boolean, :default => false
  end
end
