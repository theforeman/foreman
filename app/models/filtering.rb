class Filtering < ActiveRecord::Base
  attr_accessible :filter_id, :permission_id

  belongs_to :filter
  belongs_to :permission
end
