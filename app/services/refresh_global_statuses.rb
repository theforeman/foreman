class RefreshGlobalStatuses
  def self.call(hosts = Host::Managed.all)
    new(hosts).call
  end

  def initialize(hosts)
    @hosts = hosts
  end

  def call
    new_global_statuses.map do |status, ids|
      Host::Managed.where(id: ids).update_all(global_status: status)
    end
  end

  private

  attr_reader :hosts

  def new_global_statuses
    statuses = {}

    hosts.find_each do |host|
      new_status = host.build_global_status.status
      if host.global_status != new_status
        statuses[new_status] ||= []
        statuses[new_status] << host.id
      end
    end

    statuses
  end
end
