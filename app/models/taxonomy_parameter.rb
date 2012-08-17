class TaxonomyParameter < Parameter
  belongs_to :taxonomy, :foreign_key => :reference_id
  audited :except => [:priority], :associated_with => :taxonomy
  validates_uniqueness_of :name, :scope => :reference_id
end
