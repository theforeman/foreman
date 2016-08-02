module HostInfoProviders
  class HostParamsInfo < HostInfo::Provider
    def host_info
      { 'parameters' => host.params }
    end
  end
end
