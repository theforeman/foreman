module Foreman::Controller::Parameters::SshKey
  extend ActiveSupport::Concern

  class_methods do
    def ssh_key_params_filter
      Foreman::ParameterFilter.new(::SshKey).tap do |filter|
        filter.permit :key, :name, :user_id
      end
    end
  end

  def ssh_key_params
    self.class.ssh_key_params_filter.filter_params(params, parameter_filter_context)
  end
end
