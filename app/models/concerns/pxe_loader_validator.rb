module PxeLoaderValidator
  extend ActiveSupport::Concern

  included do
    validate :validate_pxe_loader
  end

  def validate_pxe_loader
    return unless operatingsystem && pxe_loader.present?
    loaders = operatingsystem.available_loaders
    errors.add(:pxe_loader, _("'%{loader}' is not one of %{loaders}") % {:loader => pxe_loader, :loaders => loaders.join(', ')}) unless Operatingsystem.valid_loader_name?(pxe_loader)
  end
end
