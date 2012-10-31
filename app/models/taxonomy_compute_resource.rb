class TaxonomyComputeResource < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :compute_resource

  validates_uniqueness_of :taxonomy_id, :scope => :compute_resource_id
end
