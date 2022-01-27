require 'test_helper'

class Api::V2::SettingsControllerTest < ActionController::TestCase
  describe '#index' do
    def setup
      @org = FactoryBot.create(:organization)
      @loc = FactoryBot.create(:location)
    end

    test "should get index" do
      get :index
      assert_response :success
      settings = ActiveSupport::JSON.decode(@response.body)['results']
      assert !settings.empty?
    end

    test "should get index with organization and location params" do
      get :index, params: { location_id: @loc.id, organization_id: @org.id}
      assert_response :success
      settings = ActiveSupport::JSON.decode(@response.body)['results']
      assert !settings.empty?
    end

    test "should get index with pagination string params" do
      get :index, params: { page: "1", per_page: "5"}
      assert_response :success
      settings = ActiveSupport::JSON.decode(@response.body)['results']
      assert !settings.empty?
    end

    context 'with globals set' do
      setup { SETTINGS.merge!(oauth_active: true) }
      teardown { SETTINGS.delete(:oauth_active) }

      it 'retrieves the global value' do
        get :index, params: { per_page: 'all' }
        assert_response :success
        settings = ActiveSupport::JSON.decode(@response.body)['results']
        oauth_active = settings.detect { |set| set['name'] == 'oauth_active' }
        assert_not_nil oauth_active
        assert true, oauth_active['value']
      end
    end
  end

  describe '#show' do
    test "should show default value" do
      get :show, params: { :id => 'foreman_url' }
      assert_response :success
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert !show_response.empty?
      assert_equal Setting['foreman_url'], show_response['value']
    end

    test "should show set value" do
      Setting['foreman_url'] = value = 'http://cool-foreman.example.net'
      get :show, params: { :id => 'foreman_url' }
      assert_response :success
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert !show_response.empty?
      assert_equal value, show_response['value']
    end

    test "properly show overriden false value" do
      Setting['host_power_status'] = value = false
      get :show, params: { :id => 'host_power_status' }
      assert_response :success
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal value, show_response['value']
    end

    test "validate show attributes" do
      get :show, params: { :id => 'foreman_url' }
      assert_response :success
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_include show_response.keys, 'updated_at'
    end
  end

  test "should not update setting" do
    put :update, params: { :id => settings(:attributes1).to_param, :setting => { } }
    assert_response 422
  end

  test "should parse string values to integers" do
    setting = Setting.where(:settings_type => 'integer').first
    put :update, params: { :id => setting.to_param, :setting => { :value => "100" } }
    assert_response :success
    assert_equal 100, Setting[setting.name]
  end

  test "should accept integer values" do
    setting = Setting.where(:settings_type => 'integer').first
    put :update, params: { :id => setting.to_param, :setting => { :value => 120 } }
    assert_response :success
    assert_equal 120, Setting[setting.name]
  end

  test "should parse string values to ararys" do
    setting = Setting.where(:settings_type => 'array').first
    put :update, params: { :id => setting.to_param, :setting => { :value => "['baz','foo']" } }
    assert_response :success
    assert_equal ['baz', 'foo'], Setting[setting.name]
  end

  test "should accept array values" do
    setting = Setting.where(:settings_type => 'array').first
    put :update, params: { :id => setting.to_param, :setting => { :value => ['foo', 'bar'] } }
    assert_response :success
    assert_equal ['foo', 'bar'], Setting[setting.name]
  end

  test_attributes :pid => 'fb8b0bf1-b475-435a-926b-861aa18d31f1'
  test "should update login page footer text with long value" do
    value = RFauxFactory.gen_alpha 1000
    put :update, params: { :id => 'login_text', :setting => { :value => value } }
    assert_equal JSON.parse(@response.body)['value'], value, "Can't update login_text setting with valid value #{value}"
  end

  test_attributes :pid => '7a56f194-8bde-4dbf-9993-62eb6ab10733'
  test "should update login page footer text with empty value" do
    put :update, params: { :id => 'login_text', :setting => { :value => "" } }
    assert_equal JSON.parse(@response.body)['value'], "", "Can't update login_text setting with empty value"
  end

  test "settings list should show full name column" do
    get :index
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert response["results"][0].key?("full_name")
  end

  test "should update setting as system admin" do
    user = user_one_as_system_admin
    setting = Setting.where(:settings_type => 'integer').first
    as_user user do
      put :update, params: { :id => setting.to_param, :setting => { :value => "100" } }
    end
    assert_response :success
  end

  test "should view setting as system admin" do
    user = user_one_as_system_admin
    setting = Setting.first
    as_user user do
      get :show, params: { :id => setting.to_param }
    end
    assert_response :success
  end

  private

  def user_one_as_system_admin
    user = users(:one)
    user.roles = [Role.default, Role.find_by_name('System admin')]
    user
  end
end
