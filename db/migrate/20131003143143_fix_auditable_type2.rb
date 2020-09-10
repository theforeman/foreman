class FixAuditableType2 < ActiveRecord::Migration[4.2]
  def up
    # Taxonomy
    Audit.where(:auditable_type => 'Taxonomy').each do |audit|
      taxonomy_type = Taxonomy.find_by_id(audit.auditable_id).try(:type)
      audit.update_attribute(:auditable_type, taxonomy_type) if taxonomy_type
    end

    # ComputeResource
    Audit.where("auditable_type LIKE '%Foreman::Model%'").update_all(:auditable_type => 'ComputeResource')
  end

  def down
    # Taxonomy
    Audit.where(:auditable_type => ['Organization', 'Location']).update_all(:auditable_type => 'Taxonomy')

    # ComputeResource
    Audit.where(:auditable_type => 'ComputeResource').each do |audit|
      cr_type = ComputeResource.find_by_id(audit.auditable_id).try(:type)
      audit.update_attribute(:auditable_type, cr_type) if cr_type
    end
  end
end
