require 'test_helper'

class Api::V2::AuditsControllerTest < ActionController::TestCase
  test 'preserves audit search restrictions when applying taxonomy visibility' do
    os = FactoryBot.create(:operatingsystem, :with_auditing)
    allowed = os.audits.reorder(:id).last
    os.update!(:name => 'ChangedOS')
    role = FactoryBot.create(:role)
    FactoryBot.create(:filter, :role => role,
      :permissions => [Permission.find_by!(:name => 'view_audit_logs')], :search => "id = #{allowed.id}")
    user = users(:one)
    user.roles = [role]
    User.current = user

    get :index, session: set_session_user(user)

    assert_response :success
    assert_equal [allowed.id], assigns(:audits).map(&:id)
  end

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
