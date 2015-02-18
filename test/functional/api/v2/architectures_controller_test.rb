require 'test_helper'

class Api::V2::ArchitecturesControllerTest < ActionController::TestCase
  arch_i386 = { :name => 'i386' }

  def user_one_as_anonymous_viewer
    users(:one).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  def user_one_as_manager
    users(:one).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Manager')]
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:architectures)
    architectures = ActiveSupport::JSON.decode(@response.body)
    assert !architectures.empty?
  end

  test "should show individual record" do
    get :show, { :id => architectures(:x86_64).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create architecture" do
    assert_difference('Architecture.count') do
      post :create, { :architecture => arch_i386 }
    end
    assert_response :success
  end

  test "should update architecture" do
    put :update, { :id => architectures(:x86_64).to_param, :architecture => { } }
    assert_response :success
  end

  test "should destroy architecture" do
    assert_difference('Architecture.count', -1) do
      delete :destroy, { :id => architectures(:s390).to_param }
    end
    assert_response :success
  end

  test "should not destroy used architecture" do
    assert_difference('Architecture.count', 0) do
      delete :destroy, { :id => architectures(:x86_64).to_param }
    end
    assert_response :unprocessable_entity
  end

  test "user with viewer rights should fail to update an architecture" do
    user_one_as_anonymous_viewer
    as_user :one do
      put :update, { :id => architectures(:x86_64).to_param, :architecture => { } }
    end
    assert_response :forbidden
  end

  test "user with manager rights should success to update an architecture" do
    user_one_as_manager
    as_user :one do
      put :update, { :id => architectures(:x86_64).to_param, :architecture => { } }
    end
    assert_response :success
  end

  test "user with viewer rights should succeed in viewing architectures" do
    user_one_as_anonymous_viewer
    as_user :one do
      get :index, { }
    end
    assert_response :success
  end
end
