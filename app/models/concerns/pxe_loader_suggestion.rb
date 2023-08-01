module PxeLoaderSuggestion
  extend ActiveSupport::Concern
  def suggest_default_pxe_loader
    return if pxe_loader.presence

    from_os_params = try(:operatingsystem).try(:parameters).try(:find_by_name, "pxe-loader")
    self.pxe_loader = from_os_params.try(:value)
    return if pxe_loader.presence

    self.pxe_loader = try(:operatingsystem).try(:preferred_loader).presence || ''
  end
end
