class Image < ApplicationRecord
  include Authorizable

  audited :except => [ :password ]

  belongs_to :operatingsystem
  belongs_to :compute_resource
  belongs_to :architecture
  has_many_hosts :dependent => :nullify
  attr_reader :password_changed
  after_save :unset_password_changed
  before_validation :set_password_changed, :if => Proc.new { |audit| audit.password_changed? }

  validates_lengths_from_database
  validates :username, :operatingsystem_id, :compute_resource_id, :architecture_id, :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => [:compute_resource_id, :operatingsystem_id]}
  validates :uuid, :presence => true, :uniqueness => {:scope => :compute_resource_id}
  validate :uuid_exists?

  scoped_search :on => [:name, :username], :complete_value => true
  scoped_search :relation => :compute_resource, :on => :name, :complete_value => :true, :rename => "compute_resource"
  scoped_search :relation => :architecture, :on => :id, :rename => "architecture", :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :relation => :operatingsystem, :on => :id, :rename => "operatingsystem", :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :on => :user_data, :complete_value => {:true => true, :false => false}

  def password_changed_changed?
    changed.include?('password_changed')
  end

  def set_password_changed
    @password_changed = true
    attribute_will_change!('password_changed')
  end

  def unset_password_changed
    @password_changed = false
  end

  private

  def uuid_exists?
    return true if compute_resource.blank?
    errors.add(:uuid, _("could not be found in %s") % compute_resource.name) unless compute_resource.image_exists?(uuid)
  end
end
