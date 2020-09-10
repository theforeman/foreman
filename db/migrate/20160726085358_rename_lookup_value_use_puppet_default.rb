class RenameLookupValueUsePuppetDefault < ActiveRecord::Migration[4.2]
  def change
    # this method is revesible
    rename_column :lookup_values, :use_puppet_default, :omit
  end
end
