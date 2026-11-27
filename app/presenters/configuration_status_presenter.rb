class ConfigurationStatusPresenter < HostStatusPresenter
  private

  def total_data
    @total_data ||= data
  end

  def owned_data
    ids = Host::Managed.search_for('owner = current_user').select(:id)
    @owned_data ||= data(HostStatus::ConfigurationStatus.where(host_id: { id: ids }))
  end

  def data(scope = HostStatus::ConfigurationStatus)
    scope.joins(:host)
         .includes(
           host: [
             :hostgroup,
             :operatingsystem,
             :interfaces,
             :location,
             :organization,
             :last_report_object,
           ]
         )
         .select(&:relevant?)
         .map(&:get_status)
         .tally
  end
end
