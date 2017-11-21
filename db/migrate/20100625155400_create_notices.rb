class CreateNotices < ActiveRecord::Migration[4.2]
  def up
    # These are notice messages
    create_table :notices do |t|
      t.string  :content, :null => false, :limit => 1024
      t.boolean :global,  :null => false, :default => true
      t.string  :level,   :null => false, :limit => 255
      t.timestamps null: true
    end
    # Global messages have to be acknowledged by every user individually
    create_table :user_notices, :id => false do |t|
      t.references :user
      t.references :notice
    end
  end

  def down
    drop_table :user_notices
    drop_table :notices
  end
end
