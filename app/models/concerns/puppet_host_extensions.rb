module PuppetHostExtensions
  def populate_fields_from_facts(parser, type, source_proxy)
    super

    type ||= 'puppet'
    return unless type == 'puppet'

    if Setting[:update_environment_from_facts]
      set_non_empty_values parser, [:environment]
    else
      self.environment ||= parser.environment if parser.environment.present?
    end

    # if proxy authentication is enabled and we have no puppet proxy set and the upload came from puppet,
    # use it as puppet proxy.
    proxy_pool = source_proxy.try(:pools).try(:first)
    self.puppet_proxy_pool ||= proxy_pool
  end
end
