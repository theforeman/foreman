class ChangeAuditedChangesInAudits < ActiveRecord::Migration
  # Sets the audited_changes to MEDIUMTEXT type in mysql
  def up
    if %w[mysql mysql2].include? ActiveRecord::Base.connection.instance_values['config'][:adapter]
      change_column :audits, :audited_changes, :mediumtext
    end
  end

  def down
    if %w[mysql mysql2].include? ActiveRecord::Base.connection.instance_values['config'][:adapter]
      change_column :audits, :audited_changes, :text
    end
  end
end
