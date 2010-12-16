require 'test_helper'

class SubnetsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Subnet.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Subnet.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to subnets_url
  end

  def test_edit
    get :edit, :id => Subnet.first
    assert_template 'edit'
  end

  def test_update_invalid
    Subnet.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Subnet.first
    assert_template 'edit'
  end

  def test_update_valid
    Subnet.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Subnet.first
    assert_redirected_to subnets_url
  end

  def test_should_not_destroy_if_used_by_hosts
    subnet = Subnet.first
    delete :destroy, :id => subnet
    assert_redirected_to subnets_url
    assert Subnet.exists?(subnet.id)
  end


  def test_destroy
    subnet = Subnet.first
    subnet.hosts.clear
    delete :destroy, :id => subnet
    assert_redirected_to subnets_url
    assert !Subnet.exists?(subnet.id)
  end
end
