require 'test_helper'

class Api::V1::PtablesControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'ptable_test', :layout => 'd-i partman-auto/disk' }

  test "should get index" do
    as_user :admin do
      get :index, { }
    end
    assert_response :success
    assert_not_nil assigns(:ptables)
    ptables = ActiveSupport::JSON.decode(@response.body)
    assert !ptables.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, { :id => ptables(:one).to_param }
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create ptable" do
    as_user :admin do
      assert_difference('Ptable.count') do
        post :create, { :ptable => valid_attrs }
      end
    end
    assert_response :success
  end

  test "should update ptable" do
    as_user :admin do
      put :update, { :id => ptables(:one).to_param, :ptable => { } }
    end
    assert_response :success
  end

  test "should NOT destroy ptable in use" do
    as_user :admin do
      assert_difference('Ptable.count', -0) do
        delete :destroy, { :id => ptables(:one).to_param }
      end
    end
    assert_response :unprocessable_entity
  end

  test "should destroy ptable that is NOT in use" do
    as_user :admin do
      assert_difference('Ptable.count', -1) do
        delete :destroy, { :id => ptables(:four).to_param }
      end
    end
    assert_response :success
  end


end
