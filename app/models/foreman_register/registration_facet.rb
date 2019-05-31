# frozen_string_literal: true

module ForemanRegister
  class RegistrationFacet < ApplicationRecord
    include Facets::Base
    include Encryptable

    encrypts :jwt_secret

    validates_lengths_from_database

    validates :jwt_secret, uniqueness: true
    validates :host, presence: true, allow_blank: false

    before_create :generate_jwt_secret, prepend: true, unless: proc { |f| f.jwt_secret.present? }

    private

    def generate_jwt_secret
      loop do
        self.jwt_secret = SecureRandom.base64
        break unless ForemanRegister::RegistrationFacet.find_by(jwt_secret: jwt_secret)
      end
    end
  end
end
