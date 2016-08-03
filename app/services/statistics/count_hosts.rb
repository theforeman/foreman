module Statistics
  class CountHosts < Base
    def calculate
      Host.authorized(:view_hosts, Host).count_distribution(count_by)
    end
  end
end
