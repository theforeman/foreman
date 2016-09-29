class EnsureAllHostnamesAreLowercase < ActiveRecord::Migration
  def up
    execute "UPDATE hosts SET name=LOWER(name)"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
