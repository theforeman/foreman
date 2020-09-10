# frozen_string_literal: true

require 'test_helper'

module ForemanRegister
  class RegistrationFacetTest < ActiveSupport::TestCase
    should validate_presence_of(:host)

    let(:host) { FactoryBot.create(:host, :managed) }

    it 'generates jwt_secret before creation' do
      facet = ForemanRegister::RegistrationFacet.new(host: host)
      facet.save
      assert_not_nil facet.jwt_secret
    end
  end
end
