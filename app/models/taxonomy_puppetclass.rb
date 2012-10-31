class TaxonomyPuppetclass < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :puppetclass

  validates_uniqueness_of :taxonomy_id, :scope => :puppetclass_id
end
