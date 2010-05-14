require 'test_helper'

class DomainParameterTest < ActiveSupport::TestCase
  test "should have a domain_id" do
    parameter = DomainParameter.create(:name => "value", :value => "value")
    assert !parameter.save

    domain = Domain.find_or_create_by_name("domain")
    parameter.domain_id = domain.id
    assert parameter.save
  end

  test "should have a unique parameter name" do
    p1 = DomainParameter.new(:name => "parameter", :value => "value1", :domain_id => Domain.first)
    assert p1.save
    p2 = DomainParameter.new(:name => "parameter", :value => "value2", :domain_id => Domain.first)
    assert !p2.save
  end
end

