class ChangeTokenValueType < ActiveRecord::Migration[5.2]
  def up
    # in case the AddTypeToToken migration was already executed, we need to endure consistency since it was modified
    unless column_exists? :tokens, :value, :text
      change_column :tokens, :value, :text
    end
  end
end
