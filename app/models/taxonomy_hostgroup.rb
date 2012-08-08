class TaxonomyHostgroup < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :hostgroup

  validates_uniqueness_of :taxonomy_id, :scope => :hostgroup_id
end
