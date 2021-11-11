class EnsureAllHostnamesAreLowercase < ActiveRecord::Migration[4.2]
  def up
  end

  def down
    raise ActiveRecord::IrreversibleMigration[4.2]
  end
end
