class RenameLookupKeyUsePuppetDefault < ActiveRecord::Migration[4.2]
  def change
    # this method is revesible
    rename_column :lookup_keys, :use_puppet_default, :omit
  end
end
