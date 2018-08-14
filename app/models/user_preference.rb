class UserPreference < ApplicationRecord
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  belongs_to :user
  serialize :value

  validates :user_id, :name, :kind, :presence => true
  validates_lengths_from_database
  validates :kind, inclusion: { in: ['Tour', 'Table'] }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :kind, :complete_value => :true
end
