class Environment < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include Authorizable
  include Parameterizable::ByName

  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)

  has_many_hosts
  has_many :hostgroups
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"

  validates :name, :uniqueness => true, :presence => true, :alphanumeric => true
  has_many :template_combinations, :dependent => :destroy
  has_many :provisioning_templates, :through => :template_combinations

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("environments.name")
    end
  }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :hosts_count
  scoped_search :on => :hostgroups_count
end

require_dependency 'environments/puppet_environment'
