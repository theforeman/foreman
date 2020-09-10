class ChangeTemplateAuditsType < ActiveRecord::Migration[4.2]
  def up
    known_types = Template.descendants.map(&:to_s)
    Audit.where(:auditable_type => known_types).update_all(:auditable_type => 'Template')
    Audit.where(:associated_type => known_types).update_all(:associated_type => 'Template')
  end

  def down
    Template.descendants.each do |type|
      Audit.where(:auditable_type => 'Template', :auditable_id => type.pluck(:id)).update_all(:auditable_type => type.to_s)
      Audit.where(:associated_type => 'Template', :associated_id => type.pluck(:id)).update_all(:associated_type => type.to_s)
    end
  end
end
