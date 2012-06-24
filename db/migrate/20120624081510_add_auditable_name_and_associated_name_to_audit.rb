class AddAuditableNameAndAssociatedNameToAudit < ActiveRecord::Migration
  def self.up
    add_column :audits, :auditable_name, :string
    add_column :audits, :associated_name, :string
    Audit.reset_column_information
    Audit.includes(:auditable, :associated).find_in_batches do |audits|
      audits.each do |audit|
        auditable_name  ||= audit.auditable.try(:to_label) rescue nil
        associated_name ||= audit.associated.try(:to_label) rescue nil
        audit.update_single_attribute(:auditable_name, "'#{auditable_name}'") if auditable_name
        audit.update_single_attribute(:associated_name, "'#{associated_name}'") if associated_name
      end
    end
  end

  def self.down
    remove_column :audits, :associated_name
    remove_column :audits, :auditable_name
  end
end
