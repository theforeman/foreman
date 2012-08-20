require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
  end

  test "should get edit" do
    location = Location.new :name => "location1"
    assert location.save!
    get :edit, {:id => location.name}, set_session_user
    assert_response :success
  end

  test "should update location" do
    name = "location1"
    location = Location.create :name => name

    post :update, {:commit => "Submit", :id => location.name, :location => {:name => name} }, set_session_user
    updated_location = Location.find_by_id(location.id)

    assert updated_location.name = name
    assert_redirected_to location_path
  end

  test "should not allow saving another location with same name" do
    name = "location_dup_name"
    location = Location.new :name => name
    assert location.save!

    put :create, {:commit => "Submit", :location => {:name => name} }, set_session_user
    assert @response.body.include? "has already been taken"
  end

  test "should delete null location" do
    name = "location1"
    location = Location.new :name => name
    assert location.save!

    assert_difference('Location.count', -1) do
      delete :destroy, {:id => location.name}, set_session_user
      assert_contains flash[:notice], "Successfully destroyed #{name}."
    end
  end
end
