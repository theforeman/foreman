module PxeLoaderTest
  extend ActiveSupport::Concern
  included do
    context "pxe loader" do
      setup do
        disable_orchestration
        Operatingsystem.any_instance.stubs(:preferred_loader).returns("Grub2 UEFI")
        Redhat.any_instance.stubs(:preferred_loader).returns("Grub2 UEFI")
      end

      test "should be created for host or hostgroup using suggestion" do
        post :create, params: valid_attrs_with_root(basic_attrs)
        refute_nil last_record.operatingsystem
        assert_equal "Grub2 UEFI", last_record.pxe_loader
        assert_response :created
      end

      test "should be created for host or hostgroup with Grub2 UEFI" do
        post :create, params: valid_attrs_with_root(:pxe_loader => "Grub2 UEFI SecureBoot")
        assert_equal "Grub2 UEFI SecureBoot", last_record.pxe_loader
        assert_response :created
      end

      test "should be created for host or hostgroup with non-PXE" do
        post :create, params: valid_attrs_with_root(:pxe_loader => "None")
        assert_equal "None", last_record.pxe_loader
        assert_response :created
      end
    end
  end
end
