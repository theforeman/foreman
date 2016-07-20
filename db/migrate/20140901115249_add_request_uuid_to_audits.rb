class AddRequestUuidToAudits < ActiveRecord::Migration[4.2]
  def up
    add_column :audits, :request_uuid, :string, :limit => 255 unless column_exists? :audits, :request_uuid
    add_index  :audits, :request_uuid unless index_exists? :audits, :request_uuid
  end

  def down
    remove_column :audits, :request_uuid
  end
end
