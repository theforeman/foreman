require 'test_helper'

class Api::V2::ArchitecturesControllerTest < ActionController::TestCase
  arch_i386 = { :name => 'i386' }

  def user_one_as_anonymous_viewer
    users(:one).roles = [Role.default, Role.find_by_name('Viewer')]
  end

  def user_one_as_manager
    users(:one).roles = [Role.default, Role.find_by_name('Manager')]
  end

  all_per_page_test

  context 'index test' do
    def setup
      @org = FactoryBot.create(:organization)
      @loc = FactoryBot.create(:location)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:architectures)
      architectures = ActiveSupport::JSON.decode(@response.body)
      assert !architectures.empty?
    end

    test "should get index with organization and location params" do
      get :index, params: { :location_id => @loc.id, :organization_id => @org.id}
      assert_response :success
      assert_not_nil assigns(:architectures)
      architectures = ActiveSupport::JSON.decode(@response.body)
      assert !architectures.empty?
    end
  end

  test "should show individual record" do
    get :show, params: { :id => architectures(:x86_64).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create architecture" do
    assert_difference('Architecture.count') do
      post :create, params: { :architecture => arch_i386 }
    end
    assert_response :created
  end

  test "should not create architecture with invalid name" do
    assert_difference('Architecture.count', 0) do
      post :create, params: { :architecture => {:name => ''}}
    end
    assert_response :unprocessable_entity
  end

  test "should update architecture" do
    put :update, params: { :id => architectures(:x86_64).to_param, :architecture => {:name => 'newx86_64'} }
    assert_response :success
  end

  test "should not update architecture with invalid name" do
    arch = Architecture.first
    arch_name = arch.name
    put :update, params: { :id => arch.id, :architecture => {:name => ''} }
    assert_response :unprocessable_entity
    arch.reload
    assert_equal arch.name, arch_name
  end

  test "should destroy architecture" do
    assert_difference('Architecture.count', -1) do
      delete :destroy, params: { :id => architectures(:s390).to_param }
    end
    assert_response :success
  end

  test "should not destroy used architecture" do
    assert_difference('Architecture.count', 0) do
      delete :destroy, params: { :id => architectures(:x86_64).to_param }
    end
    assert_response :unprocessable_entity
  end

  test "user with viewer rights should fail to update an architecture" do
    user_one_as_anonymous_viewer
    as_user :one do
      put :update, params: { :id => architectures(:x86_64).to_param, :architecture => {:name => 'newx86_64'} }
    end
    assert_response :forbidden
  end

  test "user with manager rights should success to update an architecture" do
    user_one_as_manager
    as_user :one do
      put :update, params: { :id => architectures(:x86_64).to_param, :architecture => {:name => 'newx86_64'} }
    end
    assert_response :success
  end

  test "user with viewer rights should succeed in viewing architectures" do
    user_one_as_anonymous_viewer
    as_user :one do
      get :index
    end
    assert_response :success
  end

  test "403 response contains missing permissions" do
    as_user :one do
      get :index
    end
    assert_response :forbidden
    assert_includes @response.body, 'view_architectures'
  end
end
