class TaxonomyUser < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :user

  validates_uniqueness_of :taxonomy_id, :scope => :user_id
end
