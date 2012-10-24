require 'test_helper'

class Api::V1::PuppetclassesControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'test_puppetclass' }

  test "should get index" do
    as_user :admin do
      get :index, { }
    end
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
  end

  test "should create puppetclass" do
    as_user :admin do
      assert_difference('Puppetclass.count') do
        post :create, { :puppetclass => valid_attrs }
      end
    end
    assert_response :success
  end

  test "should update puppetclass" do
    as_user :admin do
      put :update, { :id => puppetclasses(:one).to_param, :puppetclass => { } }
    end
    assert_response :success
  end

  test "should destroy puppetclasss" do
    as_user :admin do
      assert_difference('Puppetclass.count', -1) do
        delete :destroy, { :id => puppetclasses(:one).to_param }
      end
    end
    assert_response :success
  end


end
