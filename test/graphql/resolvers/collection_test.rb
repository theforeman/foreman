require 'test_helper'

class CollectionResolverTest < ActiveSupport::TestCase
  let(:type) { Types::Model }
  let(:context) { { current_user: User.current } }
  let(:object) { nil }
  let(:resolver_class) { Resolvers::Generic.for(type).collection }
  let(:resolver) { resolver_class.new(object: object, context: context, field: nil) }
  let(:model1) { FactoryBot.create(:model, name: 'Example 1') }
  let(:model2) { FactoryBot.create(:model, name: 'Example 2') }

  context 'as unauthorized user' do
    setup do
      User.current = nil
    end

    it 'does not return any records' do
      result = resolver.resolve
      assert_empty result
    end
  end

  context 'as restricted user user' do
    setup do
      setup_user(:view_hosts)
    end

    it 'does not return any records' do
      result = resolver.resolve
      assert_empty result
    end
  end

  context 'as authorized user' do
    setup do
      User.current = FactoryBot.create(:user, :admin)
    end

    describe 'resolving hardware models' do
      it 'returns all records' do
        results = resolver.resolve
        assert_same_elements Model.all, results
      end

      it 'applies a search filter' do
        results = resolver.resolve(search: 'name ~Sun')
        assert_same_elements [models(:V210)], results
      end

      it 'sorts the result' do
        results = resolver.resolve(sort_by: 'name', sort_direction: 'DESC')
        assert_equal Model.all.pluck(:name).sort.reverse, results.pluck(:name)
      end

      it 'applies a search filter and sorts the result' do
        model1
        model2
        results = resolver.resolve(search: 'name ~Example', sort_by: 'name', sort_direction: 'DESC')
        assert_equal [model2.name, model1.name], results.pluck(:name)
      end

      it 'does not allow sorting by invalid field' do
        assert_raises GraphQL::ExecutionError do
          resolver.resolve(sort_by: 'invalid', sort_direction: 'DESC')
        end
      end

      it 'applies a search filter and does not allow sorting by invalid field' do
        assert_raises GraphQL::ExecutionError do
          resolver.resolve(search: 'name ~Example', sort_by: 'invalid', sort_direction: 'DESC')
        end
      end

      context 'with taxonmies' do
        let(:type) { Types::Subnet }
        setup do
          @locations = FactoryBot.create_list(:location, 2)
          @organizations = FactoryBot.create_list(:organization, 2)
          @expected_subnets = FactoryBot.create_list(:subnet_ipv4, 2, organizations: [@organizations.first], locations: [@locations.first])
          @unexpected_subnets = FactoryBot.create_list(:subnet_ipv4, 2, organizations: [@organizations.last], locations: [@locations.last])
        end

        it 'gets all subnets' do
          results = resolver.resolve
          (@expected_subnets + @unexpected_subnets).each do |subnet|
            assert_includes results, subnet
          end
        end

        it 'filters by location' do
          results = resolver.resolve(location: @locations.first.name)
          assert_same_elements @expected_subnets, results
        end

        it 'filters by organization' do
          results = resolver.resolve(organization: @organizations.first.name)
          assert_same_elements @expected_subnets, results
        end

        it 'filters by location and organization' do
          results = resolver.resolve(location: @locations.first.name, organization: @organizations.first.name)
          assert_same_elements @expected_subnets, results
        end

        it 'filters by location_id' do
          results = resolver.resolve(location_id: Foreman::GlobalId.for(@locations.first))
          assert_same_elements @expected_subnets, results
        end

        it 'filters by organization_id' do
          results = resolver.resolve(organization_id: Foreman::GlobalId.for(@organizations.first))
          assert_same_elements @expected_subnets, results
        end

        it 'filters by location_id and organization_id' do
          results = resolver.resolve(location_id: Foreman::GlobalId.for(@locations.first), organization_id: Foreman::GlobalId.for(@organizations.first))
          assert_same_elements @expected_subnets, results
        end
      end
    end
  end
end
