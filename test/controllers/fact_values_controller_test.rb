require 'test_helper'

class FactValuesControllerTest < ActionController::TestCase
  let(:host) { FactoryBot.create(:host) }
  let(:fact_name) { FactoryBot.create(:fact_name) }
  let(:fact_value) do
    FactoryBot.create(:fact_value, :fact_name => fact_name, :host => host)
  end

  def setup
    fact_value.save!
    User.current = nil
  end

  def test_index
    get :index, session: set_session_user
    assert_response :success
    assert_template FactValue.unconfigured? ? 'welcome' : 'index'
    assert_not_nil :fact_values
  end

  test 'user with viewer rights should succeed in viewing facts' do
    as_admin do
      users(:one).roles = [Role.default, Role.find_by_name('Viewer')]
    end
    get :index, session: set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  test 'when host-id is presented in params, it should be added to search with "and" operator' do
    get :index, params: {host_id: host.id, search: 'location = a'}, session: set_session_user
    assert_response :success
    assert_match "location = a and host = #{host.id}", @controller.params[:search]
  end

  def test_index_with_sort
    @request.env['HTTP_REFERER'] = fact_values_path
    get :index, params: {order: 'origin ASC'}, session: set_session_user
    assert_response :success
    assert_not_nil :fact_values
    get :index, params: {order: 'wrong ASC'}, session: set_session_user
    assert_response :redirect
  end

  describe 'CSV Export' do
    test 'csv export works' do
      get :index, params: {format: :csv}, session: set_session_user
      assert_response :success
      body = response.body
      assert_equal 2, body.lines.size
      assert_match fact_name.name, body
    end

    test 'csv exports nested values ' do
      child_fact_name_name = [fact_name.name, "child"].join(FactName::SEPARATOR)
      as_admin do
        child_fact = FactoryBot.create(:fact_name, :parent => fact_name,
                                        :name => child_fact_name_name)
        fact_name.update_attribute(:compose, true)
        fact_value.update_attribute(:fact_name, child_fact)
      end
      get :index, params: {format: :csv}, session: set_session_user
      body = response.body
      assert_response :success
      assert_equal 2, body.lines.size
      assert_match child_fact_name_name, body.to_s
    end
  end
end
