require 'test_helper'

class HostgroupsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Hostgroup.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Hostgroup.any_instance.stubs(:valid?).returns(true)
    pc = Puppetclass.first
    post :create, "hostgroup" => {"name"=>"test_it", "group_parameters_attributes"=>{"1272344174448"=>{"name"=>"x", "value"=>"y", "_destroy"=>""}}, "puppetclass_ids"=>["", pc.id.to_s]}
    assert_redirected_to hostgroups_url
  end

  def test_edit
    get :edit, :id => Hostgroup.first
    assert_template 'edit'
  end

  def test_update_invalid
    Hostgroup.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Hostgroup.first
    assert_template 'edit'
  end

  def test_update_valid
    Hostgroup.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Hostgroup.first
    assert_redirected_to hostgroups_url
  end

  def test_destroy
    hostgroup = Hostgroup.first
    delete :destroy, :id => hostgroup
    assert_redirected_to hostgroups_url
    assert !Hostgroup.exists?(hostgroup.id)
  end
end
