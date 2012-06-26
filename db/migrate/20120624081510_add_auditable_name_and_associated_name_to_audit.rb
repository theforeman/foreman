class AddAuditableNameAndAssociatedNameToAudit < ActiveRecord::Migration
  def self.up
    add_column :audits, :auditable_name, :string
    add_column :audits, :associated_name, :string
    add_index :audits, :id
    Audit.reset_column_information
    say "About to review all audits, this may take a while..."
    Audit.includes(:user, :auditable, :associated).find_in_batches do |audits|
      audits.each do |audit|
        attr = {}
        auditable_name  ||= audit.auditable.try(:to_label)  rescue nil
        associated_name ||= audit.associated.try(:to_label) rescue nil
        attr[:auditable_name] = "'#{auditable_name}'"  if auditable_name
        attr[:associated_name]= "'#{associated_name}'" if associated_name
        attr[:username]= "'#{audit.user.to_label}'"    if audit.user and audit.username.empty?
        audit.update_multiple_attribute(attr) if attr.length > 0
      end
    end
  end

  def self.down
    remove_index :audits, :id
    remove_column :audits, :associated_name
    remove_column :audits, :auditable_name
  end
end
