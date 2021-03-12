# frozen_string_literal: true

module ForemanRegister
  module HostExtensions
    extend ActiveSupport::Concern

    def registration_facet!
      registration_facet || create_registration_facet!
    end

    def registration_token
      facet = registration_facet!
      ForemanRegister::RegistrationToken.encode(self, facet.jwt_secret)
    end

    def registration_url
      ForemanRegister::RegistrationUrl.new(host: self).url
    end

    def initial_configuration_template
      provisioning_template(kind: 'host_init_config')
    end
  end
end
