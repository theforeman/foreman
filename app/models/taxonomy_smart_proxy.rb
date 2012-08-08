class TaxonomySmartProxy < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :smart_proxy

  validates_uniqueness_of :taxonomy_id, :scope => :smart_proxy_id
end
