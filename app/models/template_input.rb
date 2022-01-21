class TemplateInput < ApplicationRecord
  include ::Exportable

  class ValueNotReady < ::Foreman::Exception
  end
  class UnsatisfiedRequiredInput < ::Foreman::Exception
  end

  VALUE_TYPE = ['plain', 'search', 'date', 'resource']

  attr_exportable(:name, :required, :input_type, :description,
    :options, :advanced, :value_type, :resource_type, :default, :hidden_value)

  def to_export(include_blank = true)
    hash_to_export = super
    additions = input_type_instance.additional_to_export(self, include_blank)
    hash_to_export.merge(additions.stringify_keys)
  end

  belongs_to :template
  before_destroy :prevent_delete_if_template_is_locked
  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :input_type, :complete_value => true

  validates :name, presence: true, uniqueness: { scope: 'template_id' }
  validates :input_type, presence: true, inclusion: { in: ->(input) { input.template ? input.template.available_input_types : Foreman.input_types_registry.input_types.keys } }

  validates :value_type, inclusion: { in: VALUE_TYPE }
  validates :default, inclusion: { in: :options_array }, if: -> { options.present? }, allow_blank: true
  validate :check_if_template_is_locked
  validate :input_type_related_validations

  def input_type_instance
    Foreman.input_types_registry.get(input_type).new if input_type
  end

  def user_template_input?
    Foreman::Deprecation.deprecation_warning('2.5', 'use #input_type or #input_type_instance to determine input type')
    input_type == 'user'
  end

  def fact_template_input?
    Foreman::Deprecation.deprecation_warning('2.5', 'use #input_type or #input_type_instance to determine input type')
    input_type == 'fact'
  end

  def variable_template_input?
    Foreman::Deprecation.deprecation_warning('2.5', 'use #input_type or #input_type_instance to determine input type')
    input_type == 'variable'
  end

  def puppet_parameter_template_input?
    Foreman::Deprecation.deprecation_warning('2.5', 'use #input_type or #input_type_instance to determine input type')
    input_type == 'puppet_parameter'
  end

  def preview(scope)
    resolver(scope).preview
  end

  def value(scope)
    resolver(scope).value
  end

  def options_array
    options.blank? ? [] : options.split(/\r?\n/).map(&:strip)
  end

  def basic?
    !advanced
  end

  private

  def prevent_delete_if_template_is_locked
    if template_locked?
      errors.add(:base, _("Cannot delete template input as template is locked."))
      throw(:abort)
    end
  end

  def check_if_template_is_locked
    if template_locked?
      errors.add(:base, _('This template is locked. Please clone it to a new template to customize.'))
    end
  end

  def template_locked?
    template&.locked && !ForemanSeeder.is_seeding
  end

  def input_type_related_validations
    input_type_instance&.validate(self)
  end

  def resolver(scope)
    input_type_instance&.resolver(self, scope)
  end
end
