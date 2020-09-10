require 'test_helper'

class KeyPairsControllerTest < ActionController::TestCase
  setup do
    @compute_resource = FactoryBot.create(:ec2_cr)
  end

  test "cr with key_pair should get index" do
    get :index, params: { :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_response :success
  end

  test "cr without key_pair should not get index" do
    compute_resource = FactoryBot.create(:libvirt_cr)
    get :index, params: { :compute_resource_id => compute_resource.to_param }, session: set_session_user
    assert_response :not_found
  end

  test "should download pem file" do
    key = FactoryBot.create(:key_pair)
    get :show, params: { :compute_resource_id => @compute_resource.to_param, :id => key.id }, session: set_session_user
    assert_response :success
    assert_equal(key.secret, @response.body)
    refute @response.body.size.zero?
  end

  test "should recreate a key pair" do
    Foreman::Model::EC2.any_instance.stubs(:recreate).returns(KeyPair.create(:name => "foreman-#{Foreman.uuid}",
                                                                             :secret => "shhh",
                                                                             :compute_resource_id => @compute_resource.id))
    key_pair = FactoryBot.create(:key_pair)
    key_pair.compute_resource = @compute_resource
    post :create, params: { :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_response :redirect
    assert_redirected_to @compute_resource
    refute_nil(@compute_resource.key_pair)
    refute_equal(key_pair, @compute_resource.key_pair)
  end

  test "should remove a key" do
    Foreman::Model::EC2.any_instance.stubs(:delete_key_from_resource).returns(true)
    delete :destroy, params: { :compute_resource_id => @compute_resource.to_param, :id => "foreman-key" }, session: set_session_user
    assert_response :redirect
    assert_redirected_to @compute_resource
  end

  test "should create a key pair" do
    Foreman::Model::EC2.any_instance.stubs(:recreate).returns(KeyPair.create(:name => "foreman-#{Foreman.uuid}",
                                                                             :secret => "shhh",
                                                                             :compute_resource_id => @compute_resource.id))

    post :create, params: { :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_response :redirect
    assert_redirected_to @compute_resource
  end
end
