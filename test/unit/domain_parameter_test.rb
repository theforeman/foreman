require 'test_helper'

class DomainParameterTest < ActiveSupport::TestCase
  test "should have a reference_id" do
    parameter = DomainParameter.create(:name => "value", :value => "value")
    assert !parameter.save

    setup_user "create"
    domain = Domain.find_or_create_by_name("domain")
    parameter.reference_id = domain.id
    assert parameter.save
  end

  test "duplicate names cannot exist in a domain" do
    setup_user "create"
    parameter1 = DomainParameter.create :name => "some_parameter", :value => "value", :reference_id => Domain.first.id
    parameter2 = DomainParameter.create :name => "some_parameter", :value => "value", :reference_id => Domain.first.id
    assert !parameter2.valid?
    assert  parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  test "duplicate names can exist in different domains" do
    setup_user "create"
    parameter1 = DomainParameter.create :name => "some_parameter", :value => "value", :reference_id => Domain.first.id
    parameter2 = DomainParameter.create :name => "some_parameter", :value => "value", :reference_id => Domain.last.id
    assert parameter2.valid?
  end

  def setup_user operation, type = 'domains'
    super(operation, type) do |user|
      user.domains.destroy_all
    end
  end

end

