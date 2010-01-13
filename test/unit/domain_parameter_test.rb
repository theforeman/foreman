require 'test_helper'

class DomainParameterTest < ActiveSupport::TestCase
  test "should have a domain_id" do
    parameter = DomainParameter.create(:name => "value", :value => "value")
    assert !parameter.save

    domain = Domain.find_or_create_by_name("domain")
    parameter.domain_id = domain.id
    assert parameter.save
  end
end

