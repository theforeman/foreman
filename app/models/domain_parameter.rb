class DomainParameter < Parameter
  belongs_to :domain, :foreign_key => :reference_id
  validates_uniqueness_of :name, :scope => :reference_id
end
