require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  should have_many(:hosts).dependent(:nullify)

  test "image is invalid if uuid invalid" do
    resource = compute_resources(:one)
    image = resource.images.build(:name => "foo", :uuid => "bar")
    ComputeResource.any_instance.stubs(:image_exists?).returns(false)
    image.valid? #trigger validations
    assert image.errors.messages.keys.include?(:uuid)
  end

  test "image scoped search for compute_resource works" do
    resource = compute_resources(:one)
    assert_includes Image.search_for("compute_resource = #{resource.name}"), images(:one)
  end
end
