class TaxonomyMedium < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :medium

  validates_uniqueness_of :taxonomy_id, :scope => :medium_id
end
