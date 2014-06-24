class CacheLookupValuesCount < ActiveRecord::Migration
  def self.up
    execute "update lookup_keys set lookup_values_count=(select count(*) from lookup_values where lookup_key_id=lookup_keys.id)"
  end

  def self.down
  end
end
