class Widget < ApplicationRecord
  belongs_to :user

  validates :user_id, :name, :template, :presence => true
  validates :sizex, :sizey, :col, :row, :numericality => {:only_integer => true}

  serialize :data

  before_validation :default_values

  scope :available, -> { where(template: Dashboard::Manager.default_widgets.map { |w| w[:template] }) }

  def default_values
    self.sizex ||= 4
    self.sizey ||= 1
    self.col   ||= 1
    self.row   ||= 1
    self.data  ||= {}
  end

  # Returns widget representation as the hash object Dashboard::Manager uses in memory
  def to_hash
    { :template => template, :sizex => sizex, :sizey => sizey, :name => name }
  end
end
