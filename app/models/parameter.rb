class Parameter < ApplicationRecord
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include HiddenValue
  include KeyType
  include KeyValueValidation

  validates_lengths_from_database

  include Authorizable
  validates :name, :presence => true, :no_whitespace => true

  validate :validate_and_cast_value
  serialize :value

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :type, :complete_value => true
  scoped_search :on => :value, :complete_value => true
  scoped_search :on => :key_type, :aliases => [:parameter_type], :complete_value => true

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
  scoped_search :relation => :location, :on => :name, :complete_value => true, :rename => 'location_name'
  scoped_search :relation => :organization, :on => :name, :complete_value => true, :rename => 'organization_name'

  default_scope -> { order("parameters.name") }

  before_create :set_priority
  before_save :set_searchable_value, :set_default_key_type

  PRIORITY = { :common_parameter => 0,
               :organization_parameter => 10,
               :location_parameter => 20,
               :domain_parameter => 30,
               :subnet_parameter => 40,
               :os_parameter => 50,
               :group_parameter => 60,
               :host_parameter => 70,
             }

  def editable_by_user?
    Parameter.authorized(:edit_params).where(:id => id).exists?
  end

  def self.type_priority(type)
    PRIORITY.fetch(type.to_s.underscore.to_sym, nil) unless type.nil?
  end

  def value_before_type_cast
    return self[:value] if errors[:value].present?
    self.class.format_value_before_type_cast(value, key_type)
  end

  def hash_for_include_source(source, source_name = nil)
    options = {
      :value => value, :source => source, :key_type => key_type,
      :safe_value => safe_value, :parameter_type => parameter_type,
      :hidden_value? => hidden_value?,
      :searchable_value => searchable_value
    }
    options[:source_name] = source_name if source_name
    options
  end

  private

  def set_default_key_type
    self.key_type ||= Parameter::KEY_TYPES.first
  end

  def set_searchable_value
    self.searchable_value = Parameter.format_value_before_type_cast(value, key_type)
  end

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
