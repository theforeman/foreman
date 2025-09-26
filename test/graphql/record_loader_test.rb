require 'test_helper'

class RecordLoaderTest < ActiveSupport::TestCase
  let(:model) { FactoryBot.create(:model) }

  context 'as admin user' do
    let(:user) do
      FactoryBot.create(:user, :admin)
    end

    test 'loads a single object' do
      User.current = user
      name = GraphQL::Batch.batch do
        RecordLoader.for(Model).load(model.id).then(&:name)
      end
      assert_equal model.name, name
    end

    test 'loads by global id' do
      global_id = Foreman::GlobalId.for(model)
      name = GraphQL::Batch.batch do
        RecordLoader.for(Model).load_by_global_id(global_id).then(&:name)
      end
      assert_equal model.name, name
    end
  end

  context 'as limited user' do
    let(:user) do
      setup_user 'view', 'hosts'
    end

    test 'loads a single object' do
      User.current = user
      object = GraphQL::Batch.batch do
        RecordLoader.for(Model).load(model.id).then
      end
      assert_nil object
    end
  end

  context 'with taxonomy scoping' do
    setup do
      @organization1 = FactoryBot.create(:organization)
      @organization2 = FactoryBot.create(:organization)
      @location1 = FactoryBot.create(:location)
      @location2 = FactoryBot.create(:location)
    end

    context 'for organizations' do
      let(:user) do
        user = setup_user('view', 'organizations')
        user.organizations = [@organization1]
        user.save!
        user
      end

      test 'loads organization within user scope' do
        User.current = user
        org = GraphQL::Batch.batch do
          RecordLoader.for(Organization).load(@organization1.id).then
        end
        assert_equal @organization1, org
      end

      test 'does not load organization outside user scope' do
        User.current = user
        org = GraphQL::Batch.batch do
          RecordLoader.for(Organization).load(@organization2.id).then
        end
        assert_nil org
      end

      test 'admin loads all organizations' do
        User.current = FactoryBot.create(:user, :admin)
        [@organization1, @organization2].each do |org|
          loaded_org = GraphQL::Batch.batch do
            RecordLoader.for(Organization).load(org.id).then
          end
          assert_equal org, loaded_org
        end
      end
    end

    context 'for locations' do
      let(:user) do
        user = setup_user('view', 'locations')
        user.locations = [@location1]
        user.save!
        user
      end

      test 'loads location within user scope' do
        User.current = user
        loc = GraphQL::Batch.batch do
          RecordLoader.for(Location).load(@location1.id).then
        end
        assert_equal @location1, loc
      end

      test 'does not load location outside user scope' do
        User.current = user
        loc = GraphQL::Batch.batch do
          RecordLoader.for(Location).load(@location2.id).then
        end
        assert_nil loc
      end

      test 'admin loads all locations' do
        User.current = FactoryBot.create(:user, :admin)
        [@location1, @location2].each do |loc|
          loaded_loc = GraphQL::Batch.batch do
            RecordLoader.for(Location).load(loc.id).then
          end
          assert_equal loc, loaded_loc
        end
      end
    end
  end
end
