require 'test_helper'

class DomainParameterTest < ActiveSupport::TestCase
  test "should have a reference_id" do
    parameter = DomainParameter.create(:name => "value", :value => "value")
    assert !parameter.save

    domain = Domain.find_or_create_by_name("domain")
    parameter.reference_id = domain.id
    assert parameter.save
  end

  test "duplicate names cannot exist in a domain" do
    parameter1 = DomainParameter.create :name => "some parameter", :value => "value", :reference_id => Domain.first.id
    parameter2 = DomainParameter.create :name => "some parameter", :value => "value", :reference_id => Domain.first.id
    assert !parameter2.valid?
    assert  parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  test "duplicate names can exist in different domains" do
    parameter1 = DomainParameter.create :name => "some parameter", :value => "value", :reference_id => Domain.first.id
    parameter2 = DomainParameter.create :name => "some parameter", :value => "value", :reference_id => Domain.last.id
    assert parameter2.valid?
  end
end

