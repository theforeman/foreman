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

    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"
    m.hosts << host
    assert !m.destroy
  end

  test "should update hosts_count" do
    host = FactoryGirl.create(:host)
    model = Model.create :name => "newmodel"
    assert_difference "model.hosts_count" do
      host.update_attribute(:model, model)
      model.reload
    end
  end
end
