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

end
