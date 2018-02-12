class TablePreference < ApplicationRecord
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  belongs_to :user
  validates :user_id, :name, :presence => true
  serialize :columns
  validates_lengths_from_database
end
