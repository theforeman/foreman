class Statistic < ActiveRecord::Base
  include Authorizable
  extend FriendlyId

  validates_lengths_from_database
  friendly_id :name

  attr_accessible :name, :value

  validates :name, :length => {:maximum => 255}, :presence => true, :uniqueness => true
  validates :value, :presence => true
  audited

  private

  def destroy_values(ids = [])
    Statistic.where(:id => ids).delete_all
  end
end
