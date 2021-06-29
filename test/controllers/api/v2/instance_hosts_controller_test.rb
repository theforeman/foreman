require 'test_helper'

class Api::V2::InstanceHostsControllerTest < ActionController::TestCase
  test "should get index" do
    foreman = FactoryBot.create(:host, :with_infrastructure_facet)
    FactoryBot.create(:host)

    get :index
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert_equal hosts['total'], 1
    assert_equal hosts['results'].first['id'], foreman.id
  end

  test "should return 404 when host does not exist" do
    put :update, params: { :id => 12345 }
    assert_response :not_found
  end

  test "should mark a host as foreman" do
    host = FactoryBot.create(:host)
    put :update, params: { :id => host.id }
    assert_response :created

    host.reload
    assert host.infrastructure_facet.foreman
  end

  test "destroy should mark host as non-foreman" do
    foreman = FactoryBot.create(:host, :with_infrastructure_facet)
    delete :destroy, params: { :id => foreman.id }
    assert_response :success
    foreman.reload
    refute foreman.infrastructure_facet.foreman
  end

  test "destroy on non-foreman host is a noop" do
    host = FactoryBot.create(:host)
    delete :destroy, params: { :id => host.id }
    assert_response :success
    host.reload
    assert_nil host.infrastructure_facet
  end

  test "destroy on non-foreman, but infrastructure host is a noop" do
    host = FactoryBot.create(:host, :with_infrastructure_facet)
    host.infrastructure_facet.foreman = false
    host.infrastructure_facet.save!

    delete :destroy, params: { :id => host.id }
    assert_response :success
    host.reload
    refute host.infrastructure_facet.foreman
  end
end
