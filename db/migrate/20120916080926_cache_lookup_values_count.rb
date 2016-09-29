class CacheLookupValuesCount < ActiveRecord::Migration
  def up
    execute "update lookup_keys set lookup_values_count=(select count(*) from lookup_values where lookup_key_id=lookup_keys.id)"
  end

  def down
  end
end
