require 'test_helper'

class Api::V2::PtablesControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'ptable_test', :layout => 'd-i partman-auto/disk' }

  def setup
    @ptable = FactoryBot.create(:ptable)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ptables)
    ptables = ActiveSupport::JSON.decode(@response.body)
    assert !ptables.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => @ptable.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create ptable" do
    assert_difference('Ptable.unscoped.count') do
      post :create, params: { :ptable => valid_attrs }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert response.key?('layout')
    assert_equal response['name'], valid_attrs[:name]
    assert_equal response['layout'], valid_attrs[:layout]
  end

  test "create with layout length" do
    # :BZ: 1270181
    valid_params = valid_attrs.merge(:layout => RFauxFactory.gen_alpha(5000))
    assert_difference('Ptable.unscoped.count') do
      post :create, params: { :ptable => valid_params }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('layout')
    assert_equal response['layout'], valid_params[:layout]
  end

  test "create with one character name" do
    # :BZ: 1229384
    valid_params = valid_attrs.merge(:name => RFauxFactory.gen_alpha(1))
    assert_difference('Ptable.unscoped.count') do
      post :create, params: { :ptable => valid_params }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal response['name'], valid_params[:name]
  end

  test "should create ptable with os family" do
    valid_params = valid_attrs.merge(:os_family => 'Redhat')
    assert_difference('Ptable.unscoped.count') do
      post :create, params: { :ptable => valid_params }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('os_family')
    assert_equal response['os_family'], valid_params[:os_family]
  end

  test "should create ptable with organization" do
    organization_id = Organization.first.id
    assert_difference('Ptable.unscoped.count') do
      post :create, params: { :ptable => valid_attrs.merge(:organization_ids => [organization_id]) }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('organizations')
    organization_ids = response['organizations'].map { |org| org['id']}
    assert_equal organization_ids.length, 1
    assert_include organization_ids, organization_id
  end

  test "should update name" do
    new_name = 'new ptable name'
    put :update, params: { :id => @ptable.id, :ptable => { :name => new_name } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal response['name'], new_name
  end

  test "should update layout" do
    new_layout = 'new ptable layout'
    put :update, params: { :id => @ptable.id, :ptable => { :layout => new_layout } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('layout')
    assert_equal response['layout'], new_layout
  end

  test "should update os family" do
    @ptable.os_family = 'Redhat'
    assert @ptable.save
    new_os_family = 'Coreos'
    put :update, params: { :id => @ptable.id, :ptable => { :os_family => new_os_family } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('os_family')
    assert_equal response['os_family'], new_os_family
  end

  test "should not create with invalid name" do
    assert_difference('Ptable.unscoped.count', 0) do
      post :create, params: { :ptable => valid_attrs.merge(:name => '') }
    end
    assert_response :unprocessable_entity
  end

  test "should not create with invalid layout" do
    assert_difference('Ptable.unscoped.count', 0) do
      post :create, params: { :ptable => valid_attrs.merge(:layout => '') }
    end
    assert_response :unprocessable_entity
  end

  test "should not update with invalid name" do
    put :update, params: { :id => @ptable.id, :ptable => { :name => ''} }
    assert_response :unprocessable_entity
  end

  test "should not update with invalid layout" do
    put :update, params: { :id => @ptable.id, :ptable => { :layout => ''} }
    assert_response :unprocessable_entity
  end

  test "search ptable" do
    get :index, params: { :search =>  @ptable.name,  :format => 'json' }
    assert_response :success, "search ptable name: '#{@ptable.name}' failed with code: #{@response.code}"
    response = JSON.parse(@response.body)
    assert_equal response['results'].length, 1
    assert_equal response['results'][0]['id'], @ptable.id
  end

  test "search ptable by name and organization" do
    # :BZ: 1375788
    org = Organization.first
    @ptable.organizations = [org]
    assert @ptable.save
    get :index, params: {:search =>  @ptable.name, :organization_id => org.id,  :format => 'json' }
    assert_response :success, "search ptable by name and organization failed with code: #{@response.code}"
    response = JSON.parse(@response.body)
    assert_equal response['results'].length, 1
    assert_equal response['results'][0]['id'], @ptable.id
  end

  test "should created ptable with unwrapped 'layout'" do
    assert_difference('Ptable.unscoped.count') do
      post :create, params: valid_attrs
    end
    assert_response :created
  end

  test "should update ptable" do
    put :update, params: { :id => @ptable.to_param, :ptable => valid_attrs }
    assert_response :success
  end

  test "should assign operating system" do
    put :update, params: { :id => @ptable.to_param, :ptable => {
      :operatingsystem_ids => [operatingsystems(:redhat).to_param] } }
    assert_response :success
    get :show, params: { :id => @ptable.to_param }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal operatingsystems(:redhat).id, show_response["operatingsystems"].first["id"]
  end

  test "should NOT destroy ptable in use" do
    FactoryBot.create(:host, :ptable_id => @ptable.id)
    assert_difference('Ptable.unscoped.count', 0) do
      delete :destroy, params: { :id => @ptable.to_param }
    end
    assert_response :unprocessable_entity
  end

  test "should destroy ptable that is NOT in use" do
    assert_difference('Ptable.unscoped.count', -1) do
      delete :destroy, params: { :id => @ptable.to_param }
    end
    assert_response :success
  end

  test "should add audit comment" do
    Ptable.auditing_enabled = true
    Ptable.any_instance.stubs(:valid?).returns(true)
    ptable = FactoryBot.create(:ptable)
    put :update, params: { :id => ptable.to_param,
                           :ptable => { :audit_comment => "aha", :template => "tmp" } }
    assert_response :success
    assert_equal "aha", ptable.audits.last.comment
  end

  test 'should clone template' do
    original_ptable = FactoryBot.create(:ptable)
    post :clone, params: { :id => original_ptable.to_param,
                           :ptable => {:name => 'MyClone'} }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert_equal(template['name'], 'MyClone')
    assert_equal(template['template'], original_ptable.template)
  end

  test 'export should export the erb of the template' do
    ptable = FactoryBot.create(:ptable)
    get :export, params: { :id => ptable.to_param }
    assert_response :success
    assert_equal 'text/plain', response.content_type
    assert_equal ptable.to_erb, response.body
  end

  test 'clone name should not be blank' do
    post :clone, params: { :id => FactoryBot.create(:ptable).to_param,
                           :ptable => {:name => ''} }
    assert_response :unprocessable_entity
  end

  test "should import partition table" do
    ptable = FactoryBot.create(:ptable, :template => 'a')
    post :import, params: { :ptable => { :name => ptable.name, :template => 'b'} }
    assert_response :success
    assert_equal 'b', Ptable.unscoped.find_by_name(ptable.name).template
  end
end
