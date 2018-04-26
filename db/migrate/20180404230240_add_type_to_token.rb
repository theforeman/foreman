class AddTypeToToken < ActiveRecord::Migration[5.1]
  def change
    add_column :tokens, :type, :string, default: 'Token::Build', null: false, index: true
  end
end
