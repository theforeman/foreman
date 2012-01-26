class EnsureAllHostnamesAreLowercase < ActiveRecord::Migration
  def self.up
    execute "UPDATE hosts SET name=LOWER(name)"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
