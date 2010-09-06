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

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_domains"
      role.permissions = ["#{operation}_domains".to_sym]
      @one.roles = [role]
      @one.domains = []
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create when permitted" do
    setup_user "create"
    as_admin do
      @one.domains = [domains(:mydomain)]
    end
    record =  DomainParameter.create :name => "dummy", :value => "value", :reference_id => domains(:mydomain).id
    assert record.valid?
    assert !record.new_record?
  end

  test "user with create permissions should not be able to create when not permitted" do
    setup_user "create"
    as_admin do
      @one.domains = [domains(:mydomain)]
    end
    record =  DomainParameter.create :name => "dummy", :value => "value", :reference_id => domains(:yourdomain).id
    assert record.valid?
    assert record.new_record?
  end

  test "user with create permissions should be able to create when unconstrained" do
    setup_user "create"
    as_admin do
      @one.domains = []
    end
    record =  DomainParameter.create :name => "dummy", :value => "value", :reference_id => domains(:mydomain).id
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  DomainParameter.create :name => "dummy", :value => "value", :reference_id => domains(:mydomain).id
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  DomainParameter.first
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  DomainParameter.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  DomainParameter.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  DomainParameter.first
    record.name = "renamed"
    assert !record.save
  end
end

