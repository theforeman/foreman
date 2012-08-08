class TaxonomyDomain < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :domain

  validates_uniqueness_of :taxonomy_id, :scope => :domain_id
end
