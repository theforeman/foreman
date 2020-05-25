class DropPuppetClassIdFromLookUpKey < ActiveRecord::Migration[6.0]
  def change
    remove_column :lookup_keys, :puppetclass_id, :integer
  end
end
