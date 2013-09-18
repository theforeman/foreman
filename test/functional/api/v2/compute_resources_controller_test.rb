require 'test_helper'

class Api::V2::ComputeResourcesControllerTest < ActionController::TestCase

  def setup
    Fog.mock!
  end

  def teardown
    Fog.unmock!
  end

  test "should get available images" do

    img = Object.new
    img.stubs(:name).returns('some_image')
    img.stubs(:id).returns('123')

    Foreman::Model::EC2.any_instance.stubs(:available_images).returns([img])

    get :available_images, { :id => compute_resources(:ec2).to_param }
    assert_response :success
    available_images = ActiveSupport::JSON.decode(@response.body)
    assert !available_images.empty?
  end

end
