class Volume < ActiveRecord::Base
  belongs_to :compute_resource

  scoped_search :on => :name,   :complete_value => true
  scoped_search :on => :status, :complete_value => true
  scoped_search :on => :availability_zone, :complete_value => true
  scoped_search :in => :compute_resources, :on => :name, :complete_value => :true, :rename => "compute_resource"
end
