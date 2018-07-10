require 'test_helper'

class Api::V2::AuditsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:audits)
    audits = ActiveSupport::JSON.decode(@response.body)
    assert !audits.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => audits(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test 'should show audit for parent resource only' do
    host = FactoryBot.create(:host, :managed)
    host.reload
    host.model = Model.first
    host.save!
    host.reload
    expected_audits = host.audits

    get :index, params: { :host_id => host.id }
    assert_response :success
    audits = ActiveSupport::JSON.decode(@response.body)
    assert_equal expected_audits.count, audits['results'].count
  end

  test "should return permissions passing include_permissions in index" do
    get :index, params: { :include_permissions => true }
    assert_response :success
    resp = ActiveSupport::JSON.decode(@response.body)
    assert resp["can_create"]
  end
end
