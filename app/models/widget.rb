class Widget < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :name, :template, :presence => true
  validates :sizex, :sizey, :col, :row, :numericality => {:only_integer => true}

  serialize :data

  before_validation  :default_values

  def default_values
    self.sizex ||= 4
    self.sizey ||= 1
    self.col   ||= 1
    self.row   ||= 1
    self.hide  ||= false
    self.data  ||= {}
  end
end
