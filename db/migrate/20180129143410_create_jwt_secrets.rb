class CreateJwtSecrets < ActiveRecord::Migration[5.1]
  def change
    create_table :jwt_secrets do |t|
      t.string :token, index: { unique: true }, null: false
      t.references :user, null: false, type: :integer, foreign_key: true
      t.timestamps null: false
    end
  end
end
