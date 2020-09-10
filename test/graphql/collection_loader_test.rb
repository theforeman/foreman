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
end
