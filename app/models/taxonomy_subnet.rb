class TaxonomySubnet < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :subnet

  validates_uniqueness_of :taxonomy_id, :scope => :subnet_id
end
