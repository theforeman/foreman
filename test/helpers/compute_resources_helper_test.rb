require 'test_helper'

class ComputeResourcesHelperTest < ActionView::TestCase
  class DummyController
    include ComputeResourcesHelper

    delegate :controller, to: :@context
    def initialize(context)
      @context = context
    end
  end

  let :instance do
    DummyController.new(self)
  end

  describe '.list_datacenters' do
    it 'properly catches fingerpint exception' do
      compute = FactoryBot.build(:compute_resource)
      compute.stubs(:datacenters).raises(Foreman::FingerprintException, 'Wrong fingerprint')
      instance.controller.action_name = 'test_connection'
      instance.list_datacenters(compute)
      _(compute.errors.messages[:pubkey_hash].first).must_include 'Wrong fingerprint'
    end
  end
end
