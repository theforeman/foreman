class RemoveImagePasswordAudit < ActiveRecord::Migration[4.2]
  def up
    Audited::Audit.where(:auditable_type => 'Image').where('audited_changes LIKE ?', '%password%').find_each do |audit|
      if audit.audited_changes.has_key?('password')
        audit.audited_changes.delete('password')
        audit.audited_changes['password_changed'] = [true, nil]
        audit.save(:validate => false)
      end
    end
  end

  def down
    # nothing to do
  end
end
