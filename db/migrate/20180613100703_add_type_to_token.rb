class AddTypeToToken < ActiveRecord::Migration[5.1]
  def up
    remove_foreign_key :tokens, :column => :host_id if foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
    remove_index :tokens, :host_id if index_exists? :tokens, :host_id # was unique
    add_index :tokens, :host_id
    add_foreign_key :tokens, :hosts, :name => "tokens_host_id_fk" unless foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
    add_column :tokens, :type, :string, default: 'Token::Build', null: false, index: true
    change_column :tokens, :value, :text
  end

  def down
    change_column :tokens, :value, :string, limit: 255
    remove_column :tokens, :type
    remove_foreign_key :tokens, :column => :host_id if foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
    remove_index :tokens, :host_id if index_exists? :tokens, :host_id
    add_index :tokens, :host_id, :unique => true
    add_foreign_key :tokens, :hosts, :name => "tokens_host_id_fk" unless foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
  end
end
