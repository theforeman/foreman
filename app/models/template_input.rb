class TemplateInput < ApplicationRecord
  include ::Exportable

  class ValueNotReady < ::Foreman::Exception
  end
  class UnsatisfiedRequiredInput < ::Foreman::Exception
  end

  TYPES = { :user => N_('User input'), :fact => N_('Fact value'), :variable => N_('Variable'),
            :puppet_parameter => N_('Puppet parameter') }.with_indifferent_access
  VALUE_TYPE = ['plain', 'search', 'date']

  attr_exportable(:name, :required, :input_type, :fact_name, :variable_name, :puppet_class_name,
    :puppet_parameter_name, :description, :options, :advanced, :value_type,
    :resource_type, :default, :hidden_value)

  belongs_to :template
  before_destroy :prevent_delete_if_template_is_locked
  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :input_type, :complete_value => true

  validates :name, :presence => true, :uniqueness => { :scope => 'template_id' }
  validates :input_type, :presence => true, :inclusion => TemplateInput::TYPES.keys

  validates :fact_name, :presence => { :if => :fact_template_input? }
  validates :variable_name, :presence => { :if => :variable_template_input? }
  validates :puppet_parameter_name, :puppet_class_name, :presence => { :if => :puppet_parameter_template_input? }
  validates :value_type, inclusion: { in: VALUE_TYPE }
  validates :default, inclusion: { in: :options_array }, if: -> { options.present? }, allow_blank: true
  validate :check_if_template_is_locked

  def user_template_input?
    input_type == 'user'
  end

  def fact_template_input?
    input_type == 'fact'
  end

  def variable_template_input?
    input_type == 'variable'
  end

  def puppet_parameter_template_input?
    input_type == 'puppet_parameter'
  end

  def preview(scope)
    get_resolver(scope).preview
  end

  def value(scope)
    get_resolver(scope).value
  end

  def options_array
    options.blank? ? [] : options.split(/\r?\n/).map(&:strip)
  end

  def basic?
    !advanced
  end

  private

  def prevent_delete_if_template_is_locked
    if template&.locked
      errors.add(:base, _("Cannot delete template input as template is locked."))
      throw(:abort)
    end
  end

  def check_if_template_is_locked
    if template&.locked
      errors.add(:base, _('This template is locked. Please clone it to a new template to customize.'))
    end
  end

  def get_resolver(scope)
    resolver_class = case input_type
                     when 'user'
                       InputResolver::UserInputResolver
                     when 'fact'
                       InputResolver::FactInputResolver
                     when 'variable'
                       InputResolver::VariableInputResolver
                     when 'puppet_parameter'
                       InputResolver::PuppetParameterInputResolver
                     else
                       raise "unknown template input type #{input_type.inspect}"
                     end
    resolver_class.new(self, scope)
  end
end
