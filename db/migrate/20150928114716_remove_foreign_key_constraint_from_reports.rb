class RemoveForeignKeyConstraintFromReports < ActiveRecord::Migration
  def up
    remove_foreign_key :reports, :host
  end

  def down
    add_foreign_key :reports, :hosts
  end
end
