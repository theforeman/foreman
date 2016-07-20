class ChangeTemplateTaxableTaxonomiesType < ActiveRecord::Migration[4.2]
  def up
    known_types = Template.descendants.map(&:to_s)
    TaxableTaxonomy.where(:taxable_type => known_types).update_all(:taxable_type => 'Template')
  end

  def down
    Template.descendants.each do |type|
      TaxableTaxonomy.where(:taxable_type => 'Template', :taxable_id => type.pluck(:id)).update_all(:taxable_type => type.to_s)
    end
  end
end
