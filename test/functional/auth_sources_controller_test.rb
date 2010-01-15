require 'test_helper'

class AuthSourcesControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for AuthSourceLdap model" do
    assert_not_nil AuthSourcesController.active_scaffold_config
    assert AuthSourcesController.active_scaffold_config.model == AuthSourceLdap
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create auth_source" do
    assert_difference('AuthSourceLdap.count') do
      post :create, { :commit => "Create", :record => {:name => "some_auth_source", :port => "3890", :attr_login => "Chuck_Norris", :host => "vurbia"} }
    end

    assert_redirected_to auth_sources_path
  end

  # TODO: check why there's no show action.
  # test "should show auth_source" do
    # auth_source = AuthSourceLdap.new :name => "some_auth_source", :port => "3890", :attr_login => "Chuck_Norris", :host => "vurbia"
    # assert auth_source.save!
    # get :show, :id => auth_source.id
    # assert_response :success
  # end

  test "should get edit" do
    auth_source = AuthSourceLdap.new :name => "some_auth_source", :port => "3890", :attr_login => "Chuck_Norris", :host => "vurbia"
    assert auth_source.save!
    get :edit, :id => auth_source.id
    assert_response :success
  end

  test "should update auth_source" do
    auth_source = AuthSourceLdap.new :name => "some_auth_source", :port => "3890", :attr_login => "Chuck_Norris", :host => "vurbia"
    assert auth_source.save!

    put :update, { :commit => "Update", :id => auth_source.id, :record => {:name => "some_auth_source_but_different_name"} }
    auth_source = AuthSourceLdap.find_by_id(auth_source.id)
    assert auth_source.name == "some_auth_source_but_different_name"

    assert_redirected_to auth_sources_path
  end

  test "should destroy auth_source" do
    auth_source = AuthSourceLdap.new :name => "some_auth_source", :port => "3890", :attr_login => "Chuck_Norris", :host => "vurbia"
    assert auth_source.save!
    assert_difference('AuthSource.count', -1) do
      delete :destroy, :id => auth_source.id
    end

    assert_redirected_to auth_sources_path
  end
end
