class ConvertReports < ActiveRecord::Migration[4.2]
  def up
    remove_column :reports, :log
  end

  def down
    add_column :reports, :log, :text
    say "cant recreate the data, import it again"
  end
end
