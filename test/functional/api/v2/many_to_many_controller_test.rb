require 'test_helper'

class Api::V2::ManyToManyControllerTest < ActionController::TestCase

  ######### Add/Remove Role to/from User
  test "should add one role to a user" do
    user = users(:two)
    assert_difference('user.roles.count') do
      post :create, { :user_id => user.id, :association => 'roles', :roles => roles(:edit_hosts).id }
    end
    assert_response :success
  end

  test "should add multiple roles to a user" do
    user = users(:two)
    assert_difference('user.roles.count', 2) do
      post :create, { :user_id => user.id, :association => 'roles', :roles => [roles(:edit_hosts).id, roles(:manage_compute_resources).id] }
    end
    assert_response :success
  end

  test "should add multiple roles to a user even if input is in deliminated string of ids rather than array" do
    user = users(:two)
    assert_difference('user.roles.count', 2) do
      post :create, { :user_id => user.id, :association => 'roles', :roles => "#{roles(:edit_hosts).id}, #{roles(:manage_compute_resources).id}" }
    end
    assert_response :success
  end

  test "should not add role that does not exist to user" do
    user = users(:two)
    assert_difference('user.roles.count', 0) do
      post :create, { :user_id => user.id, :association => 'roles', :roles => 123456789000 }
    end
    assert_response :unprocessable_entity
    result = ActiveSupport::JSON.decode(@response.body)
    assert_includes result['message'], "Resource Role not found for id"
  end

  test "should remove a role from a user" do
    user = users(:restricted)
    assert_difference('user.roles.count', -1) do
      delete :destroy, { :user_id => user.id, :association => 'roles', :id => roles(:viewer).id }
    end
    assert_response :success
  end

  test "should remove multiple roles from a user" do
    user = users(:restricted)
    assert_difference('user.roles.count', -2) do
      delete :destroy, { :user_id => user.id, :association => 'roles', :id => "#{roles(:manage_hosts).id},#{roles(:manage_compute_resources).id}" }
    end
    assert_response :success
  end

  test "should give error if trying to removing role the does not exist from user" do
    user = users(:two)
    assert_difference('user.roles.count', 0) do
      post :destroy, { :user_id => user.id, :association => 'roles', :id => 123456789000 }
    end
    assert_response :unprocessable_entity
    result = ActiveSupport::JSON.decode(@response.body)
    assert_includes result['message'], "Resource Role not found for id"
  end

  ######### Add/Remove User to/from Role
  test "should add one user to a role" do
    role = roles(:edit_hosts)
    assert_difference('role.users.count') do
      post :create, { :role_id => role.id, :association => 'users', :users => users(:two).id }
    end
    assert_response :success
  end

  test "should add multiple users to a role" do
    role = roles(:edit_hosts)
    assert_difference('role.users.count', 2) do
      post :create, { :role_id => role.id, :association => 'users', :users => [users(:two).id, users(:internal).id] }
    end
    assert_response :success
  end

  test "should not add user that does not exist to role" do
    role = roles(:edit_hosts)
    assert_difference('role.users.count', 0) do
      post :create, { :role_id => role.id, :association => 'users', :users => 123456 }
    end
    assert_response :unprocessable_entity
  end

  test "should remove a user from a role" do
    role = roles(:viewer)
    assert_difference('role.users.count', -1) do
      delete :destroy, { :role_id => role.id, :association => 'users', :id => users(:restricted).id }
    end
    assert_response :success
  end

  test "should remove multiple users from a role" do
    role = roles(:viewer)
    role.users << users(:internal)
    assert_difference('role.users.count', -2) do
      delete :destroy, { :role_id => role.id, :association => 'users', :id => "#{users(:restricted).id}, #{users(:internal).id}" }
    end
    assert_response :success
  end


  ######### Add/Remove Architecture to/from Operating system
  test "should add one architecture to a operatingsystem" do
    operatingsystem = operatingsystems(:redhat)
    assert_difference('operatingsystem.architectures.count') do
      post :create, { :operatingsystem_id => operatingsystem.id, :association => 'architectures', :architectures => architectures(:sparc).id }
    end
    assert_response :success
  end

  test "should add multiple architectures to a operatingsystem" do
    operatingsystem = operatingsystems(:redhat)
    assert_difference('operatingsystem.architectures.count', 2) do
      post :create, { :operatingsystem_id => operatingsystem.id, :association => 'architectures', :architectures => [architectures(:sparc).id, architectures(:s390).id] }
    end
    assert_response :success
  end

  test "should not add architecture that does not exist to operatingsystem" do
    operatingsystem = operatingsystems(:redhat)
    assert_difference('operatingsystem.architectures.count', 0) do
      post :create, { :operatingsystem_id => operatingsystem.id, :association => 'architectures', :architectures => 9999999999 }
    end
    assert_response :unprocessable_entity
  end

  test "should remove a architecture from a operatingsystem" do
    operatingsystem = operatingsystems(:redhat)
    assert_difference('operatingsystem.architectures.count', -1) do
      delete :destroy, { :operatingsystem_id => operatingsystem.id, :association => 'architectures', :id => architectures(:x86_64).id }
    end
    assert_response :success
  end

  test "should remove multiple architectures from a operatingsystem" do
    operatingsystem = operatingsystems(:redhat)
    operatingsystem.architectures << architectures(:sparc)
    assert_difference('operatingsystem.architectures.count', -2) do
      delete :destroy, { :operatingsystem_id => operatingsystem.id, :association => 'architectures', :id => "#{architectures(:x86_64).id}, #{architectures(:sparc).id}" }
    end
    assert_response :success
  end


  ######### Add/Remove Role to/from Usergroup
  test "should add one role to a usergroup" do
    usergroup = usergroups(:superadmins)
    assert_difference('usergroup.roles.count') do
      post :create, { :usergroup_id => usergroup.id, :association => 'roles', :roles => roles(:edit_hosts).id }
    end
    assert_response :success
  end

  test "should remove a role from a usergroup" do
    usergroup = usergroups(:superadmins)
    assert_difference('usergroup.roles.count', -1) do
      delete :destroy, { :usergroup_id => usergroup.id, :association => 'roles', :id => roles(:manage_compute_resources).id }
    end
    assert_response :success
  end

  ######### Add/Remove Environment to/from Location
  test "should add one environment to a location" do
    location = taxonomies(:location1)
    assert_difference('location.environments.count') do
      post :create, { :location_id => location.id, :association => 'environments', :environments => environments(:global_puppetmaster).id }
    end
    assert_response :success
  end

  test "should remove an environment from a location" do
    location = taxonomies(:location1)
    assert_difference('location.environments.count', -1) do
      delete :destroy, { :location_id => location.id, :association => 'environments', :id => environments(:production).id }
    end
    assert_response :success
  end

  ######### Add/Remove Puppetclass to/from Host
  test "should add one puppetclass to a host" do
    host = hosts(:one)
    assert_difference('host.puppetclasses.count') do
      post :create, { :host_id => host.id, :association => 'puppetclasses', :puppetclasses => puppetclasses(:two).id }
    end
    assert_response :success
  end

  test "should remove an puppetclass from a host" do
    host = hosts(:one)
    assert_difference('host.puppetclasses.count', -1) do
      delete :destroy, { :host_id => host.id, :association => 'puppetclasses', :id => puppetclasses(:one).id }
    end
    assert_response :success
  end

  ######### Add/Remove Config Group to/from location
  test "should add one config_group to a hostgroup" do
    hostgroup = hostgroups(:common)
    assert_difference('hostgroup.config_groups.count') do
      post :create, { :hostgroup_id => hostgroup.id, :association => 'config_groups', :config_groups => config_groups(:two).id }
    end
    assert_response :success
  end

  test "should remove an config_group from a hostgroup" do
    hostgroup = hostgroups(:common)
    assert_difference('hostgroup.config_groups.count', -1) do
      delete :destroy, { :hostgroup_id => hostgroup.id, :association => 'config_groups', :id => config_groups(:one).id }
    end
    assert_response :success
  end

  ######### Add/Remove Location to/from Organization
  test "should add one location to an organization" do
    organization = taxonomies(:organization1)
    assert_difference('organization.locations.count') do
      post :create, { :organization_id => organization.id, :association => 'locations', :locations => taxonomies(:location2).id }
    end
    assert_response :success
  end

  test "should remove a location from an organization" do
    organization = taxonomies(:organization1)
    assert_difference('organization.locations.count', -1) do
      delete :destroy, { :organization_id => organization.id, :association => 'locations', :id => taxonomies(:location1).id }
    end
    assert_response :success
  end

end