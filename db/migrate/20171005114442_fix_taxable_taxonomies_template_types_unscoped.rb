class FixTaxableTaxonomiesTemplateTypesUnscoped < ActiveRecord::Migration[4.2]
  def up
    TaxableTaxonomy.unscoped.where(:taxable_type => 'Template', :taxable_id => Ptable.unscoped.pluck(:id)).update_all(:taxable_type => 'Ptable')
    TaxableTaxonomy.unscoped.where(:taxable_type => 'Template', :taxable_id => ProvisioningTemplate.unscoped.pluck(:id)).update_all(:taxable_type => 'ProvisioningTemplate')
  end

  def down
    TaxableTaxonomy.unscoped.where(:taxable_type => ['Ptable', 'ProvisioningTemplate']).update_all(:taxable_type => 'Template')
  end
end
