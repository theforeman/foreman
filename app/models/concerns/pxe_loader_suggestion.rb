module PxeLoaderSuggestion
  extend ActiveSupport::Concern
  def suggest_default_pxe_loader
    self.pxe_loader ||= self.try(:operatingsystem).try(:parameters).try(:find_by_name, "pxe-loader").try(:value)
    self.pxe_loader ||= self.try(:operatingsystem).try(:preferred_loader) if self.respond_to?(:pxe_loader)
  end
end
