class Image < ActiveRecord::Base
  include Authorizable

  attr_accessible :name, :compute_resource_id, :compute_resource_name, :operatingsystem_id,
    :operatingsystem_name, :architecture_id, :architecture_name, :username, :password, :uuid,
    :user_data, :iam_role

  audited :allow_mass_assignment => true

  belongs_to :operatingsystem
  belongs_to :compute_resource
  belongs_to :architecture
  has_many_hosts :dependent => :nullify

  validates_lengths_from_database
  validates :username, :name, :operatingsystem_id, :compute_resource_id, :architecture_id, :presence => true
  validates :uuid, :presence => true, :uniqueness => {:scope => :compute_resource_id}
  validate :uuid_exists?

  scoped_search :on => [:name, :username], :complete_value => true
  scoped_search :in => :compute_resource, :on => :name, :complete_value => :true, :rename => "compute_resource"
  scoped_search :in => :architecture, :on => :id, :rename => "architecture", :complete_enabled => false, :only_explicit => true
  scoped_search :in => :operatingsystem, :on => :id, :rename => "operatingsystem", :complete_enabled => false, :only_explicit => true
  scoped_search :on => :user_data, :complete_value => {:true => true, :false => false}

  private

  def uuid_exists?
    return true if compute_resource.blank?
    errors.add(:uuid, _("could not be found in %s") % compute_resource.name) unless compute_resource.image_exists?(uuid)
  end
end
