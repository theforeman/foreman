class EnsureAllHostnamesAreLowercase < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE hosts SET name=LOWER(name)"
  end

  def down
    raise ActiveRecord::IrreversibleMigration[4.2]
  end
end
