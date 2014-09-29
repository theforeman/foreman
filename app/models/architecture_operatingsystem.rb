class ArchitectureOperatingsystem < ActiveRecord::Base

  audited :associated_with => :operatingsystem, :allow_mass_assignment => true
  belongs_to :architecture
  belongs_to :operatingsystem

  validates :architecture_id, :presence => true
  validates :operatingsystem_id, :presence => true, :uniqueness => {:scope => :architecture_id}

end
