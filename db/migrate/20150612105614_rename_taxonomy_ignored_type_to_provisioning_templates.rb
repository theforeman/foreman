class RenameTaxonomyIgnoredTypeToProvisioningTemplates < ActiveRecord::Migration[4.2]
  class FakeTaxonomy < ApplicationRecord
    self.table_name = 'taxonomies'

    serialize :ignore_types, Array
  end

  def up
    swap_name('ConfigTemplate', 'ProvisioningTemplate')
  end

  def down
    swap_name('ProvisioningTemplate', 'ConfigTemplate')
  end

  private

  def swap_name(old, new)
    User.reset_column_information
    FakeTaxonomy.where("ignore_types LIKE '%#{old}%'").all.each do |taxonomy|
      taxonomy.ignore_types.delete(old)
      taxonomy.ignore_types.push(new)
      taxonomy.save(:validate => false)
    end
  end
end
