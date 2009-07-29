class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.references :host, :null => false
      t.text       :log,  :limit => 50.kilobytes, :null => false
      t.datetime   :reported_at
      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end
end
