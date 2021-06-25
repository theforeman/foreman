require 'test_helper'

class Api::V2::InstanceHostsControllerTest < ActionController::TestCase
  test "should return 404 when host does not exist" do
    put :update, params: { :id => 12345 }
    assert_response :not_found
  end

  test "should mark a host as foreman" do
    host = FactoryBot.create(:host)
    put :update, params: { :id => host.id }
    assert_response :created

    host.reload
    assert host.infrastructure_facet.foreman_instance
  end

  test "marking a foreman host as foreman is a noop" do
    host = FactoryBot.create(:host, :with_infrastructure_facet)
    put :update, params: { :id => host.id }
    assert_response :ok

    host.reload
    assert host.infrastructure_facet.foreman_instance
  end

  test "should return 403 if user is not admin" do
    host = FactoryBot.create(:host)
    setup_user 'view', 'hosts'
    put :update, params: { :id => host.id }
    assert_response :unauthorized
  end

  test 'should list hosts forming the foreman instance' do
    FactoryBot.create(:host)
    foreman = FactoryBot.create(:host, :with_infrastructure_facet)

    get :index
    assert_response :ok
    data = JSON.parse(response.body)
    assert_equal data['total'], 1
    assert_equal data['results'].first['id'], foreman.id
  end

  test "destroy should mark host as non-foreman" do
    foreman = FactoryBot.create(:host, :with_infrastructure_facet)
    delete :destroy, params: { :id => foreman.id }
    assert_response :no_content
    foreman.reload
    refute foreman.infrastructure_facet.foreman_instance
  end

  test "destroy on non-foreman host is a noop" do
    host = FactoryBot.create(:host)
    delete :destroy, params: { :id => host.id }
    assert_response :not_found
    host.reload
    assert_nil host.infrastructure_facet
  end

  test "destroy on non-foreman, but infrastructure host is a noop" do
    host = FactoryBot.create(:host, :with_infrastructure_facet)
    host.infrastructure_facet.foreman_instance = false
    host.infrastructure_facet.save!

    delete :destroy, params: { :id => host.id }
    assert_response :not_found
    host.reload
    refute host.infrastructure_facet.foreman_instance
  end

  test "should return 403 if user is not admin" do
    host = FactoryBot.create(:host)
    setup_user 'view', 'hosts'
    put :destroy, params: { :id => host.id }
    assert_response :unauthorized
  end
end
