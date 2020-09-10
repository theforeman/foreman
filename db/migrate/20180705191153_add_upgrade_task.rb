class AddUpgradeTask < ActiveRecord::Migration[5.1]
  def change
    create_table :upgrade_tasks do |t|
      t.column :name, :string, :null => false
      t.column :task_name, :string, :null => false
      t.column :long_running, :boolean, :default => false, :null => false
      t.column :always_run, :boolean, :default => false, :null => false
      t.column :skip_failure, :boolean, :default => false, :null => false
      t.column :last_run_time, :datetime, :null => true
      t.column :ordering, :integer, :null => false, :default => 100
      t.column :subject, :string, :null => false
      t.timestamps
    end

    add_index :upgrade_tasks, :name, :unique => true
  end
end
