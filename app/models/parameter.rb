class Parameter < ApplicationRecord
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include HiddenValue
  include EncryptValue
  include KeyType
  include KeyValueValidation

  validates_lengths_from_database

  include Authorizable
  validates :name, :presence => true, :no_whitespace => true

  validate :validate_and_cast_value
  serialize :value

  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
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
  before_save :encrypt_hidden_parameter_value

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

  def value=(val)
    if hidden_value? && val.to_s == HIDDEN_VALUE
      return
    end
    super
  end

  def value
    v = self[:value]
    if v.is_a?(String) && matches_prefix?(v)
      v = decrypt_field(v)
    end
    cast_loaded_value(v)
  end

  def value_before_type_cast
    return self[:value] if errors[:value].present?
    return safe_value if hidden_value?
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
    if hidden_value?
      self.searchable_value = HIDDEN_VALUE
    else
      self.searchable_value = Parameter.format_value_before_type_cast(value, key_type)
    end
  end

  def encrypt_hidden_parameter_value
    return unless hidden_value?
    return if encryption_key.blank?

    current = self[:value]
    return if current.nil?

    plain = if current.is_a?(String)
              current
            else
              Parameter.format_value_before_type_cast(current, key_type).to_s
            end

    return if plain.blank?
    return if matches_prefix?(plain)
    return if plain == HIDDEN_VALUE

    self[:value] = encrypt_field(plain)
  end

  def cast_loaded_value(v)
    return v if v.nil? || !v.is_a?(String) || v.contains_erb?
    return v if key_type.blank? || key_type.to_s == 'string'

    Foreman::Parameters::Caster.new(
      self,
      :attribute_name => :value,
      :to => key_type,
      :value => v
    ).cast
  rescue StandardError
    v
  end

  def set_priority
    self.priority = Parameter.type_priority(type)
  end

  def skip_strip_attrs
    ['value']
  end
end
