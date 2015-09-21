class AddRequestUuidToAudits < ActiveRecord::Migration
  def up
    add_column :audits, :request_uuid, :string unless column_exists? :audits, :request_uuid
    add_index :audits, :request_uuid rescue nil
  end

  def down
    remove_column :audits, :request_uuid
  end
end
