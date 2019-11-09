class AddAuditableNameAndAssociatedNameToAudit < ActiveRecord::Migration[4.2]
  def up
    add_column :audits, :auditable_name, :string, :limit => 255 unless column_exists? :audits, :auditable_name
    add_column :audits, :associated_name, :string, :limit => 255 unless column_exists? :audits, :associated_name
    add_index :audits, :id unless index_exists? :audits, :id
    Audit.reset_column_information
    say "About to review all audits, this may take a while..."
    Audit.includes(:user, :auditable, :associated).find_in_batches do |audits|
      audits.each do |audit|
        attr = {}
        auditable_name ||= audit.auditable.try(:to_label) rescue nil
        associated_name ||= audit.associated.try(:to_label) rescue nil
        attr[:auditable_name] = auditable_name if auditable_name
        attr[:associated_name] = associated_name if associated_name
        if audit.username.empty? && audit.user
          username = audit.user.to_label rescue nil
          attr[:username] = username unless username.empty?
        end
        audit.update_multiple_attribute(attr) unless attr.empty?
      end
    end
  end

  def down
    remove_index :audits, :id               if  index_exists?  :audits, :id
    remove_column :audits, :associated_name if  column_exists? :audits, :associated_name
    remove_column :audits, :auditable_name  if  column_exists? :audits, :auditable_name
  end
end
