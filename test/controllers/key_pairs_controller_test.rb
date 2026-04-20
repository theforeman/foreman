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
    key = FactoryBot.create(:key_pair, :compute_resource => @compute_resource)
    get :show, params: { :compute_resource_id => @compute_resource.to_param, :id => key.id }, session: set_session_user
    assert_response :success
    assert_equal(key.secret, @response.body)
    refute @response.body.size.zero?
  end

  test "should not download key pair when id belongs to a different compute resource" do
    other_cr = FactoryBot.create(:ec2_cr)
    other_key = FactoryBot.create(:key_pair, :compute_resource => other_cr)
    get :show, params: { :compute_resource_id => @compute_resource.to_param, :id => other_key.id }, session: set_session_user
    assert_response :not_found
  end

  test "should not download another organization's key pair using own compute resource in url" do
    org1 = taxonomies(:organization1)
    org2 = taxonomies(:organization2)
    loc = taxonomies(:location1)
    cr_owned = FactoryBot.create(:ec2_cr, :organizations => [org1], :locations => [loc])
    cr_other = FactoryBot.create(:ec2_cr, :organizations => [org2], :locations => [loc])
    FactoryBot.create(:key_pair, :compute_resource => cr_owned)
    other_key = FactoryBot.create(:key_pair, :compute_resource => cr_other)

    setup_user "view", "keypairs", nil, :one
    get :show, params: { :compute_resource_id => cr_owned.to_param, :id => other_key.id }, session: set_session_user(:one)
    assert_response :not_found
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
