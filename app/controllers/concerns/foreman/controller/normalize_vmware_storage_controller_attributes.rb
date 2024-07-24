module Foreman::Controller::NormalizeVmwareStorageControllerAttributes
  extend ActiveSupport::Concern

  private

  def normalize_vmware_storage_controller_attributes(attrs)
    ctrls_and_vol = JSON.parse(attrs["controllers"]).
      deep_transform_keys { |key| key.to_s.underscore }.
      deep_symbolize_keys
    attrs["volumes_attributes"] = ctrls_and_vol[:volumes].each_with_index.to_h { |vol, index| [index.to_s, vol] }
    attrs["nvme_controllers"], attrs["scsi_controllers"] = ctrls_and_vol[:controllers]&.partition { |controller| controller[:type].include?("VirtualNVMEController") }
    attrs.delete("controllers")
    attrs
  end
end
