class CreatePersonalAccessTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :personal_access_tokens do |t|
      t.string :token, :index => {:unique => true}, :null => false
      t.string :name, :null => false
      t.datetime :expires_at
      t.datetime :last_used_at
      t.boolean :revoked, :default => false
      t.references :user, :null => false, :index => true, :foreign_key => true

      t.timestamps :null => false
    end
  end
end
