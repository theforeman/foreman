require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  should have_many(:hosts).dependent(:nullify)

  test "image is invalid if uuid invalid" do
    image = FactoryBot.build(:image, :uuid => "bar")
    ComputeResource.any_instance.stubs(:image_exists?).returns(false)
    image.valid? #trigger validations
    assert image.errors.messages.keys.include?(:uuid)
  end

  test "image name is unique per resource and os" do
    image1 = FactoryBot.create(:image)
    image2 = FactoryBot.build(:image, name: image1.name)
    assert image2.valid?
    image2.compute_resource = image1.compute_resource
    assert image2.valid?
    image2.operatingsystem = image1.operatingsystem
    refute image2.valid?
  end

  test "image uuid is unique per compute_resource" do
    image1 = FactoryBot.create(:image)
    image2 = FactoryBot.build(:image, uuid: image1.uuid)
    assert image2.valid?
    image2.compute_resource = image1.compute_resource
    refute image2.valid?
  end

  test "image scoped search for compute_resource works" do
    image = FactoryBot.create(:image)
    assert_includes Image.search_for("compute_resource = #{image.compute_resource.name}"), image
  end

  context "audits for password change" do
    let(:protected_image) { FactoryBot.build(:image) }

    test "audit of password change should be saved only once, second time audited changes should not contain password_changed" do
      as_admin do
        protected_image.password = "newpassword"
        assert_valid protected_image
        assert protected_image.password_changed_changed?
        assert protected_image.password_changed
        assert_includes protected_image.changed, "password_changed"
        assert protected_image.save
        #testing after_save
        refute protected_image.password_changed_changed?
        refute protected_image.password_changed
        refute_includes protected_image.changed, "password_changed"
      end
    end

    test "audit of password change should be saved" do
      as_admin do
        assert protected_image.save
        protected_image.password = "newpassword"
        assert protected_image.save
        assert_includes protected_image.audits.last.audited_changes, "password_changed"
      end
    end

    test "audit of password change should not be saved - due to no password change" do
      as_admin do
        protected_image.name = protected_image.name + '_changed'
        refute protected_image.password_changed_changed?
        refute protected_image.password_changed
        refute_includes protected_image.changed, "password_changed"
        assert protected_image.save
        refute_includes protected_image.audits.last.audited_changes, "password_changed"
      end
    end
  end
end
