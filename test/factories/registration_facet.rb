# frozen_string_literal: true

FactoryBot.define do
  factory :registration_facet, class: 'ForemanRegister::RegistrationFacet' do
    jwt_secret { SecureRandom.base64 }
    host
  end
end
