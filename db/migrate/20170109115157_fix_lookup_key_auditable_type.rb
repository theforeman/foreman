class FixLookupKeyAuditableType < ActiveRecord::Migration[4.2]
  def up
    Audit.reorder(nil).joins('JOIN lookup_keys ON lookup_keys.id = audits.auditable_id').
         where(:auditable_type => 'LookupKey', :lookup_keys => {:type => 'VariableLookupKey'}).
         update_all(:auditable_type => 'VariableLookupKey')

    Audit.reorder(nil).joins('JOIN lookup_keys ON lookup_keys.id = audits.auditable_id').
         where(:auditable_type => 'LookupKey', :lookup_keys => {:type => 'PuppetclassLookupKey'}).
         update_all(:auditable_type => 'PuppetclassLookupKey')
  end

  def down
    Audit.where(:auditable_type => ['PuppetclassLookupKey', 'VariableLookupKey']).update_all(:auditable_type => 'LookupKey')
  end
end
