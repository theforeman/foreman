module PxeLoaderSuggestion
  extend ActiveSupport::Concern

  included do
    after_initialize :suggest_default_pxe_loader
  end

  def suggest_default_pxe_loader
    self.pxe_loader ||= self.try(:operatingsystem).try(:preferred_loader) if self.respond_to?(:pxe_loader)
  end
end
