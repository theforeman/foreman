require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end


  test "should create new host" do  
    assert_difference 'Host.count' do
      post :create, { :commit => "Create", :record => {:name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => {:id => Domain.find_or_create_by_name("company.com").id.to_s}, :operatingsystem => {:id => Operatingsystem.first.id.to_s}, :architecture => {:id => Architecture.first.id.to_s}, :environment => {:id => Environment.first.id.to_s}, :disk => "empty partition"} }
    end
  end

  test "should get edit" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"
   
    get :edit, :id => host.id
    assert_response :success
  end

  test "should update host" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    put :update, { :commit => "Update", :id => host.id, :record => {:disk => "ntfs"} }
    host2 = Host.find_by_id(host.id)
    
    assert host2.disk == "ntfs"
  end


  test "should destroy architecture" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    assert_difference('Host.count', -1) do
      delete :destroy, :id => host.id
    end
  end

end
