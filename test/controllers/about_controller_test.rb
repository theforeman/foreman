require 'test_helper'

class AboutControllerTest < ActionController::TestCase
  def test_index
    get :index, session: set_session_user
    assert_response :success
    assert_template 'index'
  end

  def test_registered_providers_list
    klass = mock('ExampleClass', :available? => true, :provider_friendly_name => 'Example Service')
    klass_string = mock('ExampleClass')
    klass_string.expects(:constantize).at_least_once.returns(klass)
    ComputeResource.expects(:registered_providers).at_least_once.returns('Example' => klass_string)
    ComputeResource.expects(:supported_providers).at_least_once.returns({})

    get :index, session: set_session_user
    assert_response :success

    assert_kind_of Array, assigns(:providers)
    example = assigns(:providers).find { |p| p[:name] == 'Example' }
    assert_equal({:friendly_name => 'Example Service', :name => 'Example', :status => :installed}, example)
  end
end
