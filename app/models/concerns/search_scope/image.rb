module SearchScope
  module Image
    extend ActiveSupport::Concern

    included do
      scoped_search :on => [:name, :username], :complete_value => true
      scoped_search :in => :compute_resources, :on => :name, :complete_value => :true, :rename => "compute_resource"
      scoped_search :in => :architecture, :on => :id, :rename => "architecture"
      scoped_search :in => :operatingsystem, :on => :id, :rename => "operatingsystem"
      scoped_search :on => :user_data, :complete_value => {:true => true, :false => false}
    end
  end
end
