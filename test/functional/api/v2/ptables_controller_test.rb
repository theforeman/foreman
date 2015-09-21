require 'test_helper'

class Api::V2::PtablesControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'ptable_test', :layout => 'd-i partman-auto/disk' }

  def setup
    @ptable = FactoryGirl.create(:ptable)
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:ptables)
    ptables = ActiveSupport::JSON.decode(@response.body)
    assert !ptables.empty?
  end

  test "should show individual record" do
    get :show, { :id => @ptable.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create ptable" do
    assert_difference('Ptable.count') do
      post :create, { :ptable => valid_attrs }
    end
    assert_response :created
  end

  test "should update ptable" do
    put :update, { :id => @ptable.to_param, :ptable => valid_attrs }
    assert_response :success
  end

  #test "should assign operating system" do
  def test_foo
    put :update, { :id => @ptable.to_param, :ptable => {
      :operatingsystem_ids => [operatingsystems(:redhat).to_param] } }
    assert_response :success
    get :show, { :id => @ptable.to_param }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal operatingsystems(:redhat).id, show_response["operatingsystems"].first["id"]
  end

  test "should NOT destroy ptable in use" do
    FactoryGirl.create(:host, :ptable_id => @ptable.id)
    assert_difference('Ptable.count', -0) do
      delete :destroy, { :id => @ptable.to_param }
    end
    assert_response :unprocessable_entity
  end

  test "should destroy ptable that is NOT in use" do
    assert_difference('Ptable.count', -1) do
      delete :destroy, { :id => @ptable.to_param }
    end
    assert_response :success
  end

  test "should add audit comment" do
    Ptable.auditing_enabled = true
    Ptable.any_instance.stubs(:valid?).returns(true)
    ptable = FactoryGirl.create(:ptable)
    put :update, { :id => ptable.to_param,
                   :ptable => { :audit_comment => "aha", :template => "tmp" } }
    assert_response :success
    assert_equal "aha", ptable.audits.last.comment
  end

  test 'should clone template' do
    original_ptable = FactoryGirl.create(:ptable)
    post :clone, { :id => original_ptable.to_param,
                   :ptable => {:name => 'MyClone'} }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert_equal(template['name'], 'MyClone')
    assert_equal(template['template'], original_ptable.template)
  end

  test 'clone name should not be blank' do
    post :clone, { :id => FactoryGirl.create(:ptable).to_param,
                   :ptable => {:name => ''} }
    assert_response :unprocessable_entity
  end
end
