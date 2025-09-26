require 'test_helper'

class CollectionLoaderTest < ActiveSupport::TestCase
  let(:model) { FactoryBot.create(:model) }
  setup do
    FactoryBot.create_list(:host, 2, model: model)
  end

  context 'as admin user' do
    let(:user) do
      FactoryBot.create(:user, :admin)
    end

    test 'loads associated records' do
      User.current = user
      hosts = GraphQL::Batch.batch do
        CollectionLoader.for(Model, :hosts).load(model).then
      end
      assert_same_elements model.hosts.pluck(:name), hosts.pluck(:name)
    end
  end

  context 'as limited user' do
    let(:user) do
      setup_user 'view', 'models'
    end

    test 'does not load the associated records' do
      User.current = user
      hosts = GraphQL::Batch.batch do
        CollectionLoader.for(Model, :hosts).load(model).then
      end
      assert_empty hosts
    end
  end

  context 'taxonomy scoping for associations' do
    context 'organization associations' do
      setup do
        @org1 = FactoryBot.create(:organization)
        @org2 = FactoryBot.create(:organization)
        @location = FactoryBot.create(:location)

        @hostgroup1 = FactoryBot.create(:hostgroup, organizations: [@org1], locations: [@location])
        @hostgroup2 = FactoryBot.create(:hostgroup, organizations: [@org2], locations: [@location])

        @user = setup_user('view', 'organizations') do |u|
          u.organizations = [@org1]
        end
      end

      test 'filters organization associations by user scope' do
        User.current = @user
        orgs = GraphQL::Batch.batch do
          CollectionLoader.for(Hostgroup, :organizations).load(@hostgroup1).then
        end
        assert_includes orgs, @org1
        assert_not_includes orgs, @org2
      end

      test 'returns empty for unauthorized organization associations' do
        User.current = @user
        orgs = GraphQL::Batch.batch do
          CollectionLoader.for(Hostgroup, :organizations).load(@hostgroup2).then
        end
        assert_empty orgs
      end
    end

    context 'location associations' do
      setup do
        @loc1 = FactoryBot.create(:location)
        @loc2 = FactoryBot.create(:location)
        @organization = FactoryBot.create(:organization)

        @hostgroup1 = FactoryBot.create(:hostgroup, locations: [@loc1], organizations: [@organization])
        @hostgroup2 = FactoryBot.create(:hostgroup, locations: [@loc2], organizations: [@organization])

        @user = setup_user('view', 'locations') do |u|
          u.locations = [@loc1]
        end
      end

      test 'filters location associations by user scope' do
        User.current = @user
        locs = GraphQL::Batch.batch do
          CollectionLoader.for(Hostgroup, :locations).load(@hostgroup1).then
        end
        assert_includes locs, @loc1
        assert_not_includes locs, @loc2
      end

      test 'returns empty for unauthorized location associations' do
        User.current = @user
        locs = GraphQL::Batch.batch do
          CollectionLoader.for(Hostgroup, :locations).load(@hostgroup2).then
        end
        assert_empty locs
      end
    end
  end

  context 'reflected_class method behavior' do
    test 'handles taxonomy-specific class resolution' do
      GraphQL::Batch.batch do
        org_loader = CollectionLoader.for(Hostgroup, :organizations)
        loc_loader = CollectionLoader.for(Hostgroup, :locations)

        assert_equal Organization, org_loader.send(:reflected_class)
        assert_equal Location, loc_loader.send(:reflected_class)
      end
    end
  end
end
