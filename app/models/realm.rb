class Realm < ActiveRecord::Base
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix

  TYPES = ["FreeIPA", "Active Directory"]

  validates_lengths_from_database
  attr_accessible :name, :realm_type, :realm_proxy_id, :realm_proxy, :location_ids, :organization_ids
  audited :allow_mass_assignment => true, :except => [:hosts_count, :hostgroups_count]
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
