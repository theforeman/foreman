module Foreman::Controller::NormalizeScsiAttributes
  extend ActiveSupport::Concern

  private

  def normalize_scsi_attributes(attrs)
    scsi_and_vol = JSON.parse(attrs["scsi_controllers"]).
      deep_transform_keys { |key| key.to_s.underscore }.
      deep_symbolize_keys
    volumes = {}
    scsi_and_vol[:volumes].each_with_index do |vol, index|
      volumes[index.to_s] = vol
    end

    attrs["scsi_controllers"] = scsi_and_vol[:scsi_controllers]
    attrs["volumes_attributes"] = volumes
    attrs
  end
end
