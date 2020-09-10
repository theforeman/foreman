class AddShouldUsePuppetDefaultToLookupValueAndKey < ActiveRecord::Migration[4.2]
  def up
    add_column :lookup_values, :use_puppet_default, :boolean, :default => false
    add_column :lookup_keys, :use_puppet_default, :boolean
  end

  def down
    remove_column :lookup_values, :use_puppet_default
    remove_column :lookup_keys, :use_puppet_default
  end
end
