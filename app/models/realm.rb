class Realm < ApplicationRecord
  audited
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include BelongsToProxies

  TYPES = ["FreeIPA", "Active Directory"]

  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)

  belongs_to_proxy :realm_proxy,
    :feature => 'Realm',
    :label => N_('Realm proxy'),
    :description => N_('Realm proxy to use within this realm'),
    :api_description => N_('Proxy ID to use within this realm'),
    :required => true

  has_many_hosts
  has_many :hostgroups

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
