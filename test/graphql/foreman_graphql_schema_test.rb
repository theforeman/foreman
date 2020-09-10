require 'test_helper'

class ForemanGraphqlSchemaTest < ActiveSupport::TestCase
  let(:schema) { ForemanGraphqlSchema }

  describe '#id_from_object' do
    let(:object) { FactoryBot.create(:model) }
    let(:type_definition) { ForemanGraphqlSchema.types['Model'] }
    let(:global_id) { Foreman::GlobalId.encode('Model', object.id) }

    test 'encodes type and object into a global id' do
      assert_equal global_id, schema.id_from_object(object, type_definition, nil)
    end
  end

  describe '#object_from_id' do
    let(:model) { FactoryBot.create(:model) }
    let(:global_id) { Foreman::GlobalId.encode('Model', model.id) }

    test 'can resolve the model_class for all types' do
      object = GraphQL::Batch.batch do
        schema.object_from_id(global_id, nil)
      end
      assert_equal model, object
    end
  end

  describe '#resolve_type' do
    test 'resolves the type for Host::Managed' do
      host = FactoryBot.build_stubbed(:host, :managed)
      assert_kind_of ::Host::Managed, host
      type = schema.resolve_type(nil, host, nil)
      assert_equal 'Host', type&.graphql_name
    end

    test 'resolves the type for Subnet' do
      subnet = FactoryBot.build_stubbed(:subnet_ipv4)
      assert_kind_of ::Subnet::Ipv4, subnet
      type = schema.resolve_type(nil, subnet, nil)
      assert_equal 'Subnet', type&.graphql_name
    end

    test 'resolves the type for a Compute Resource' do
      compute_resource = FactoryBot.build_stubbed(:vmware_cr)
      assert_kind_of ::Foreman::Model::Vmware, compute_resource
      assert_kind_of ::ComputeResource, compute_resource
      type = schema.resolve_type(nil, compute_resource, nil)
      assert_equal 'ComputeResource', type&.graphql_name
    end

    test 'resolves the type for Model' do
      model = FactoryBot.build_stubbed(:model)
      assert_kind_of ::Model, model
      type = schema.resolve_type(nil, model, nil)
      assert_equal 'Model', type&.graphql_name
    end
  end
end
