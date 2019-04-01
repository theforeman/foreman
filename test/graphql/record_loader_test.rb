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
end
