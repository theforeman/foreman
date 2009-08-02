class Environment < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  has_many :hosts
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of   :name, :with => /^\S+$/, :message => "Name cannot contain spaces"

  def to_label
    name
  end

  def to_s
    name
  end
end
