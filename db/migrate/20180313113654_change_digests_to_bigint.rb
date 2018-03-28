class ChangeDigestsToBigint < ActiveRecord::Migration[5.1]
  def up
    # messages digest
    remove_index :messages, :digest
    remove_column :messages, :digest
    add_column :messages, :digest, :bigint, :limit => 8
    Message.unscoped.all.find_each {|rec| rec.update_attribute :digest, Message.make_digest(rec.value)}
    add_index :messages, :digest

    # sources digest
    remove_index :sources, :digest
    remove_column :sources, :digest
    add_column :sources, :digest, :bigint, :limit => 8
    Source.unscoped.all.find_each {|rec| rec.update_attribute :digest, Source.make_digest(rec.value)}
    add_index :sources, :digest
  end

  def down
    # messages digest
    remove_index :messages, :digest
    remove_column :messages, :digest
    add_column :messages, :digest, :string, :limit => 40
    Message.unscoped.all.find_each {|rec| rec.update_attribute :digest, Message.make_digest_legacy(rec.value)}
    add_index :messages, :digest

    # sources digest
    remove_index :sources, :digest
    remove_column :sources, :digest
    add_column :sources, :digest, :string, :limit => 40
    Source.unscoped.all.find_each {|rec| rec.update_attribute :digest, Source.make_digest_legacy(rec.value)}
    add_index :sources, :digest
  end
end
