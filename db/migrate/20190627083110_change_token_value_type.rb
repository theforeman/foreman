class ChangeTokenValueType < ActiveRecord::Migration[5.2]
  def up
    # in case the AddTypeToToken migration was already executed, we need to endure consistency since it was modified
    unless column_exists? :tokens, :value, :text
      remove_index :tokens, :value if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      change_column :tokens, :value, :text
      add_index :tokens, :value, length: 767 if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
    end
  end
end
