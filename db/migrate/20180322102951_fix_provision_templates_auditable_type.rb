class FixProvisionTemplatesAuditableType < ActiveRecord::Migration[5.1]
  def up
    Audit.unscoped.where(:auditable_type => 'Template', :auditable_id => ProvisioningTemplate.pluck(:id)).update_all(:auditable_type => 'ProvisioningTemplate')
    Audit.unscoped.where(:auditable_type => 'Template', :auditable_id => Ptable.pluck(:id)).update_all(:auditable_type => 'Ptable')
  end

  def down
    Audit.unscoped.where(:auditable_type => ['Ptable', 'ProvisioningTemplate']).update_all(:auditable_type => 'Template')
  end
end
