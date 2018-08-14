class CreateUserPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :user_preferences do |t|
      t.string :name
      t.string :kind
      t.text :value
      t.integer :user_id

      t.timestamps
    end
  end
end
