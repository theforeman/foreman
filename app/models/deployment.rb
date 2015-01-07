class Deployment < ActiveRecord::Base
  include Authorizable
  include Taxonomix

  scoped_search :on => :name, :complete_value => :true
end
