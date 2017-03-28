class TurnDefaultValueToLookupValue < ActiveRecord::Migration
  class FakeLookupValue < ActiveRecord::Base
    self.table_name = 'lookup_values'
  end

  def up
    LookupKey.unscoped.find_each do |key|
      FakeLookupValue.create(:match => 'default', :value => key.default_value, :lookup_key_id => key.id, :omit => key.omit)
    end

    rename_column :lookup_keys, :default_value, :puppet_default_value
    remove_column :lookup_keys, :omit
  end

  def down
    rename_column :lookup_keys, :puppet_default_value, :default_value
    add_column :lookup_keys, :omit, :boolean

    default_lookup_values = LookupValue.where(:match => 'default').eager_load(:lookup_key)

    default_lookup_values.find_each do |lv|
      lv.lookup_key.update_columns(:default_value => lv.value, :omit => lv.omit)
    end

    default_lookup_values.delete_all
  end
end
