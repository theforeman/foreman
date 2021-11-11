class RemoveDuplicateTokens < ActiveRecord::Migration[4.2]
  def up
    remove_foreign_key :tokens, :column => :host_id if foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
    remove_index :tokens, :host_id if index_exists? :tokens, :host_id
    add_index :tokens, :host_id, :unique => true
    add_foreign_key :tokens, :hosts, :name => "tokens_host_id_fk" unless foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
  end

  def down
    remove_foreign_key :tokens, :column => :host_id if foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
    remove_index :tokens, :host_id if index_exists? :tokens, :host_id
    add_index :tokens, :host_id
    add_foreign_key :tokens, :hosts, :name => "tokens_host_id_fk" unless foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
  end
end
