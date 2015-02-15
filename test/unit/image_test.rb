require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test "can destroy image even if used by host and ensure host image_id is nullified" do
    image = images(:one)
    host = FactoryGirl.create(:host)
    host.update_attribute(:image_id, image.id)
    refute_nil host.image_id
    assert_difference('Image.count', -1) do
      assert image.destroy
    end
    host.reload
    assert_nil host.image_id
  end

  test "image is invalid if uuid invalid" do
    resource = compute_resources(:one)
    image = resource.images.build(:name => "foo", :uuid => "bar")
    ComputeResource.any_instance.stubs(:image_exists?).returns(false)
    image.valid? #trigger validations
    assert image.errors.messages.keys.include?(:uuid)
  end
end
