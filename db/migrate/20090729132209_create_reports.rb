class CreateReports < ActiveRecord::Migration
  def up
    create_table :reports do |t|
      t.references :host, :null => false
      t.text       :log
      t.datetime   :reported_at
      t.timestamps
    end
  end

  def down
    drop_table :reports
  end
end
