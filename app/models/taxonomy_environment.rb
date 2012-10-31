class TaxonomyEnvironment < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :environment

  validates_uniqueness_of :taxonomy_id, :scope => :environment_id
end
