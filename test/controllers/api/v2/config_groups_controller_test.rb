require 'test_helper'

class Api::V2::ConfigGroupsControllerTest < ActionController::TestCase
  test "should create config group" do
    assert_difference('ConfigGroup.count') do
      post :create, { :config_group => {:name => 'config-group', :puppetclass_ids => [puppetclasses(:one).id, puppetclasses(:four).id]} }
    end
    assert_response :created
  end

  test "should update config group" do
    name = 'new name'
    put :update, { :id => config_groups(:one).to_param,
                   :config_group => { :name => name,
                                      :puppetclass_ids => [puppetclasses(:one).id, puppetclasses(:four).id]
                                    }
                  }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal 2, response['puppetclasses'].count
  end
end
