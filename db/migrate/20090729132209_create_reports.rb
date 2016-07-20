class CreateReports < ActiveRecord::Migration[4.2]
  def up
    create_table :reports do |t|
      t.references :host, :null => false
      t.text       :log
      t.datetime   :reported_at
      t.timestamps null: true
    end
  end

  def down
    drop_table :reports
  end
end
