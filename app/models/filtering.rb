class Filtering < ActiveRecord::Base
  include AccessibleAttributes

  belongs_to :filter
  belongs_to :permission
end
