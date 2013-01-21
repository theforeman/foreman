class AddDigestToMessages < ActiveRecord::Migration
  def self.up
    remove_index :messages, :value
    add_column :messages, :digest, :string
    Message.all.map {|message| message.save }
    add_index :messages, :digest
  end

  def self.down
    remove_index :messages, :digest
    remove_column :messages, :digest
    add_index :messages, :value
  end
end
