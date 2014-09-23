class Realm < ActiveRecord::Base
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix

  TYPES = ["FreeIPA", "Active Directory"]

  validates_lengths_from_database
  audited :allow_mass_assignment => true
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)

  belongs_to :realm_proxy, :class_name => "SmartProxy"
  has_many_hosts
  has_many :hostgroups

  scoped_search :on => :hosts_count
  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :realm_type, :complete_value => true, :rename => :type

  validates :name, :presence => true, :uniqueness => true
  validates :realm_type, :presence => true, :inclusion => { :in => TYPES }
  validates :realm_proxy_id, :presence => true

  default_scope lambda {
    with_taxonomy_scope do
      order("realms.name")
    end
  }

  class Jail < ::Safemode::Jail
    allow :name, :realm_type
  end
end
