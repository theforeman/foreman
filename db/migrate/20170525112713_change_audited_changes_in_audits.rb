class ChangeAuditedChangesInAudits < ActiveRecord::Migration[4.2]
  # Sets the audited_changes to MEDIUMTEXT type in mysql
  def up
    if ['mysql', 'mysql2'].include? ActiveRecord::Base.connection.instance_values['config'][:adapter]
      change_column :audits, :audited_changes, :mediumtext
    end
  end

  def down
    if ['mysql', 'mysql2'].include? ActiveRecord::Base.connection.instance_values['config'][:adapter]
      change_column :audits, :audited_changes, :text
    end
  end
end
