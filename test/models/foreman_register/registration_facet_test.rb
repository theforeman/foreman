# frozen_string_literal: true

require 'test_helper'

module ForemanRegister
  class RegistrationFacetTest < ActiveSupport::TestCase
    should validate_presence_of(:host)

    let(:host) { FactoryBot.create(:host, :managed) }

    subject { ForemanRegister::RegistrationFacet.new(host: host) }

    should validate_uniqueness_of(:host)

    it 'generates jwt_secret before creation' do
      facet = ForemanRegister::RegistrationFacet.new(host: host)
      facet.save
      assert_not_nil facet.jwt_secret
    end

    context 'registration_facet! create race' do
      let(:existing) { ForemanRegister::RegistrationFacet.create!(host: host) }

      it 'reloads after RecordNotUnique from a concurrent create' do
        host.stubs(:registration_facet).returns(nil)
        host.stubs(:create_registration_facet!).raises(ActiveRecord::RecordNotUnique, 'duplicate key')
        host.stubs(:reload_registration_facet).returns(existing)

        assert_equal existing, host.registration_facet!
      end

      it 'reloads after RecordInvalid from the uniqueness validation' do
        invalid = ForemanRegister::RegistrationFacet.new(host: host)
        invalid.errors.add(:host, :taken)

        host.stubs(:registration_facet).returns(nil)
        host.stubs(:create_registration_facet!).raises(ActiveRecord::RecordInvalid.new(invalid))
        host.stubs(:reload_registration_facet).returns(existing)

        assert_equal existing, host.registration_facet!
      end

      it 're-raises when the reload also finds nothing' do
        host.stubs(:registration_facet).returns(nil)
        host.stubs(:create_registration_facet!).raises(ActiveRecord::RecordNotUnique, 'duplicate key')
        host.stubs(:reload_registration_facet).returns(nil)

        assert_raises(ActiveRecord::RecordNotUnique) { host.registration_facet! }
      end
    end
  end
end
