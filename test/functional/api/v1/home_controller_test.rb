require 'test_helper'

class Api::V1::HomeControllerTest < ActionController::TestCase

   test "should get index" do
     as_user :admin do
       get :index, {}
     end
     assert_response :success
   end

end

