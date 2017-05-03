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

  context "audits for password change" do
    let(:protected_image) { FactoryGirl.build(:image, :compute_resource => FactoryGirl.create(:compute_resource, :libvirt)) }

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
