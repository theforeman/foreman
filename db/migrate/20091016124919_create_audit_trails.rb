class CreateAuditTrails < ActiveRecord::Migration
  def self.up
    create_table :audit_trails do |t|
      t.column :record_id, :integer
      t.column :record_type, :string
      t.column :event, :string
      t.column :user_id, :integer
      t.column :created_at, :datetime
      t.column :description, :text

    end
  end

  def self.down
    drop_table :audit_trails
  end
end
