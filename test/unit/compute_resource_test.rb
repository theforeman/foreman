require 'test_helper'

class ComputeResourceTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_compute_resources"
      role.permissions = ["#{operation}_compute_resources".to_sym]
      @one.roles = [role]
      @one.compute_resources = []
      @one.save!
    end
    User.current = @one
  end

  test "user with edit permissions should be able to edit when permitted" do
    setup_user "edit"
    as_admin do
      @one.compute_resources = [compute_resources(:mycompute)]
    end
    record = compute_resources(:mycompute)
    assert record.update_attributes(:name => "testing")
    assert record.valid?
  end

  test "user with edit permissions should not be able to edit when not permitted" do
    setup_user "edit"
    record = compute_resources(:yourcompute)
    assert !record.update_attributes(:name => "testing")
    assert record.valid?
  end

  test "user with edit permissions should not be able to edit when unconstrained" do
    setup_user "edit"
    record = compute_resources(:mycompute)
    assert !record.update_attributes(:name => "testing")
    assert record.valid?
  end

  test "user with destroy permissions should be able to destroy when permitted" do
    setup_user "destroy"
    as_admin do
      @one.compute_resources = [compute_resources(:mycompute)]
    end
    record = compute_resources(:mycompute)
    assert record.destroy
  end

  test "user with destroy permissions should not be able to destroy when not permitted" do
    setup_user "destroy"
    record = compute_resources(:yourcompute)
    assert !record.destroy
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    as_admin do
      @one.compute_resources = [compute_resources(:mycompute)]
    end
    record = compute_resources(:mycompute)
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    as_admin do
      @one.compute_resources = [compute_resources(:mycompute)]
    end
    record      =  compute_resources(:mycompute)
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    as_admin do
      @one.compute_resources = [compute_resources(:mycompute)]
    end
    record      =  compute_resources(:mycompute)
    record.name = "renamed"
    assert !record.save
  end

  test "password is saved encrypted when updated" do
    compute_resource = compute_resources(:one)
    compute_resource.password = "123456"
    as_admin do
      assert compute_resource.save
    end
    assert_equal compute_resource.password, "123456"
    refute_equal compute_resource.password_in_db, "123456"
  end

  test "password is saved encrypted when created" do
    Fog.mock!
    compute_resource = ComputeResource.new_provider(:name => "new12345", :provider => "EC2", :url => "eu-west-1",
                                                    :user => "username", :password => "abcdef")
    as_admin do
      assert compute_resource.save!
    end
    assert_equal compute_resource.password, "abcdef"
    refute_equal compute_resource.password_in_db, "abcdef"
  end

end
