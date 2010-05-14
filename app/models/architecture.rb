class Architecture < ActiveRecord::Base
  has_many :hosts
  has_and_belongs_to_many :operatingsystems
  validates_uniqueness_of :name
  before_destroy Ensure_not_used_by.new(:hosts)
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  acts_as_audited

  def to_s
    name
  end

  def self.per_page
    25
  end
end
