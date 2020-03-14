# TODO: remove this when there is a gem or a fix for rails that validates nested attributes correctly
module ParameterValidators
  extend ActiveSupport::Concern

  included do
    validate :validate_parameters_names
  end

  def validate_parameters_names
    names = []
    errors = false
    send(parameters_symbol).each do |param|
      next unless param.new_record? # normal validation would catch this
      if names.include?(param.name)
        param.errors.add(:name, _('has already been taken'))
        errors = true
      else
        names << param.name
      end
    end
    self.errors.add(parameters_symbol, _('Please ensure the following parameters name are unique')) if errors
  end

  def parameters_symbol
    case self
      when Operatingsystem then :os_parameters
      when Hostgroup       then :group_parameters
      when Host::Managed   then :host_parameters
      when Domain          then :domain_parameters
      when Organization    then :organization_parameters
      when Location        then :location_parameters
      when Subnet          then :subnet_parameters
    end
  end
end
