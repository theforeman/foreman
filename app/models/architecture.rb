class Architecture < ActiveRecord::Base
  has_many :hosts
  has_and_belongs_to_many :operatingsystems
  validates_uniqueness_of :name
  before_destroy Ensure_not_used_by.new(:hosts)
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  acts_as_audited

  alias_attribute :to_s, :name
  alias_attribute :to_label, :name

  def self.per_page
    25
  end
end
