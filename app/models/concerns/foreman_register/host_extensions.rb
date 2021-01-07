# frozen_string_literal: true

module ForemanRegister
  module HostExtensions
    extend ActiveSupport::Concern

    def registration_facet!
      registration_facet || create_registration_facet!
    end

    def registration_token
      return nil unless registration_facet
      ForemanRegister::RegistrationToken.encode(self, facet.jwt_secret)
    end

    def registration_url
      registration_facet!
      ForemanRegister::RegistrationUrl.new(host: self).url
    end

    def registration_template
      provisioning_template(kind: 'registration')
    end
  end
end
