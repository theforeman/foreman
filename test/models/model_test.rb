require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test "should have name" do
    m = Model.new
    assert !m.save
  end

  test "name should be unique" do
    m1 = Model.new :name => "pepe"
    assert m1.save
    m2 = Model.new :name => m1.name
    assert !m2.save
  end

  test "should not be used when destroyed" do
    m = Model.create :name => "m1"
    FactoryBot.create(:host, :model => m)
    assert_equal 1, m.reload.hosts.size
    assert !m.destroy
  end

  context 'is audited' do
    test 'on creation on of a new model' do
      model = FactoryBot.build(:model, :with_auditing)

      assert_difference 'model.audits.count' do
        model.save!
      end
    end
  end
end
