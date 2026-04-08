require 'test_helper'

# Controller that calls hide_taxonomy_options WITHOUT a subsequent resource_description.
# This simulates existing controllers like ArchitecturesController.
class Api::V2::HideTaxonomySimpleController < Api::V2::BaseController
  hide_taxonomy_options

  def index
    render :json => { :location_id => params[:location_id], :organization_id => params[:organization_id] }, :status => :ok
  end
end

# Controller that calls hide_taxonomy_options WITH a subsequent resource_description.
# This simulates plugin controllers (e.g. foreman_ansible) where resource_description
# with api_base_url follows hide_taxonomy_options.
class Api::V2::HideTaxonomyWithDescriptionController < Api::V2::BaseController
  hide_taxonomy_options

  resource_description do
    api_version 'v2'
    api_base_url '/test_plugin/api'
  end

  def index
    render :json => { :location_id => params[:location_id], :organization_id => params[:organization_id] }, :status => :ok
  end
end

class Api::V2::HideTaxonomySimpleControllerTest < ActionController::TestCase
  tests Api::V2::HideTaxonomySimpleController

  test 'should drop taxonomy params from request' do
    get :index, params: { :location_id => 1, :organization_id => 2 }, session: set_session_user
    assert_response :success
    body = JSON.parse(response.body)
    assert_nil body['location_id']
    assert_nil body['organization_id']
  end

  test 'should succeed without taxonomy params' do
    get :index, session: set_session_user
    assert_response :success
  end
end

class Api::V2::HideTaxonomyWithDescriptionControllerTest < ActionController::TestCase
  tests Api::V2::HideTaxonomyWithDescriptionController

  test 'should drop taxonomy params even when resource_description follows hide_taxonomy_options' do
    get :index, params: { :location_id => 1, :organization_id => 2 }, session: set_session_user
    assert_response :success
    body = JSON.parse(response.body)
    assert_nil body['location_id']
    assert_nil body['organization_id']
  end

  test 'should succeed without taxonomy params' do
    get :index, session: set_session_user
    assert_response :success
  end
end
