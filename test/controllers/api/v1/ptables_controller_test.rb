require 'test_helper'

class Api::V1::PtablesControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'ptable_test', :layout => 'd-i partman-auto/disk' }

  def setup
    @ptable = FactoryBot.create(:ptable)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ptables)
    ptables = ActiveSupport::JSON.decode(@response.body)
    assert !ptables.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => @ptable.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create ptable" do
    assert_difference('Ptable.unscoped.count') do
      post :create, params: { :ptable => valid_attrs }
    end
    assert_response :success
  end

  test "should update ptable" do
    put :update, params: { :id => @ptable.to_param, :ptable => valid_attrs }
    assert_response :success
  end

  test "should NOT destroy ptable in use" do
    FactoryBot.create(:host, :ptable_id => @ptable.id)

    assert_difference('Ptable.unscoped.count', -0) do
      delete :destroy, params: { :id => @ptable.to_param }
    end
    assert_response :unprocessable_entity
  end

  test "should destroy ptable that is NOT in use" do
    assert_difference('Ptable.unscoped.count', -1) do
      delete :destroy, params: { :id => @ptable.to_param }
    end
    assert_response :success
  end
end
