require 'test_helper'

class ModelTest < ActiveSupport::TestCase
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
end
