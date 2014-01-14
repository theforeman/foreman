class Image < ActiveRecord::Base

  audited :allow_mass_assignment => true

  belongs_to :operatingsystem
  belongs_to :compute_resource
  belongs_to :architecture

  has_many_hosts
  validates :username, :name, :operatingsystem_id, :compute_resource_id, :architecture_id, :presence => true
  validates :uuid, :presence => true, :uniqueness => {:scope => :compute_resource_id}

  scoped_search :on => [:name, :username], :complete_value => true
  scoped_search :in => :compute_resources, :on => :name, :complete_value => :true, :rename => "compute_resource"
  scoped_search :in => :architecture, :on => :id, :rename => "architecture"
  scoped_search :in => :operatingsystem, :on => :id, :rename => "operatingsystem"
  scoped_search :on => :user_data, :complete_value => {:true => true, :false => false}

end
