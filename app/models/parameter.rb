class Parameter < ApplicationRecord
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include HiddenValue

  validates_lengths_from_database

  include Authorizable
  validates :name, :presence => true, :no_whitespace => true

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :type, :complete_value => true
  scoped_search :on => :value, :complete_value => true

  # children associations must be defined here, otherwise scoped search definitions won't find them
  belongs_to :domain, :foreign_key => :reference_id, :inverse_of => :domain_parameters
  belongs_to :operatingsystem, :foreign_key => :reference_id, :inverse_of => :os_parameters
  belongs_to :subnet, :foreign_key => :reference_id, :inverse_of => :subnet_parameters
  belongs_to_host :foreign_key => :reference_id, :inverse_of => :host_parameters
  belongs_to :hostgroup, :foreign_key => :reference_id, :inverse_of => :group_parameters
  belongs_to :location, :foreign_key => :reference_id, :inverse_of => :location_parameters
  belongs_to :organization, :foreign_key => :reference_id, :inverse_of => :organization_parameters
  # specific children search definitions, required for permission filters autocompletion
  scoped_search :relation => :domain, :on => :name, :complete_value => true, :rename => 'domain_name'
  scoped_search :relation => :operatingsystem, :on => :name, :complete_value => true, :rename => 'os_name'
  scoped_search :relation => :subnet, :on => :name, :complete_value => true, :rename => 'subnet_name'
  scoped_search :relation => :host, :on => :name, :complete_value => true, :rename => 'host_name'
  scoped_search :relation => :hostgroup, :on => :name, :complete_value => true, :rename => 'host_group_name'
  if Taxonomy.locations_enabled
    scoped_search :relation => :location, :on => :name, :complete_value => true, :rename => 'location_name'
  end
  if Taxonomy.organizations_enabled
    scoped_search :relation => :organization, :on => :name, :complete_value => true, :rename => 'organization_name'
  end

  default_scope -> { order("parameters.name") }

  before_create :set_priority

  PRIORITY = { :common_parameter => 0,
               :organization_parameter => 10,
               :location_parameter => 20,
               :domain_parameter => 30,
               :subnet_parameter => 40,
               :os_parameter => 50,
               :group_parameter => 60,
               :host_parameter => 70
             }.freeze

  def editable_by_user?
    Parameter.authorized(:edit_params).where(:id => id).exists?
  end

  def self.type_priority(type)
    PRIORITY.fetch(type.to_s.underscore.to_sym, nil) unless type.nil?
  end

  private

  def set_priority
    self.priority = Parameter.type_priority(type)
  end

  def skip_strip_attrs
    ['value']
  end
end

require_dependency 'common_parameter'
require_dependency 'domain_parameter'
require_dependency 'group_parameter'
require_dependency 'host_parameter'
require_dependency 'location_parameter'
require_dependency 'organization_parameter'
require_dependency 'os_parameter'
require_dependency 'subnet_parameter'
