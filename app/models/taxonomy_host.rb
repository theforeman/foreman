class TaxonomyHost < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :host

  validates_uniqueness_of :taxonomy_id, :scope => :host_id
end
