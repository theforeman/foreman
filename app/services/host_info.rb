module HostInfo
  class << self
    def providers
      (entries_from_plugins + local_entries).uniq
    end

    def register_info_provider(provider)
      local_entries << provider
      provider
    end

    def entries_from_plugins
      Foreman::Plugin.all.map { |plugin| plugin.info_providers }.compact.flatten
    end

    def local_entries
      @providers ||= []
    end
  end
end
