collection @host_statuses

attributes :name, :description, :ok_total_path, :ok_owned_path, :warn_total_path,
  :warn_owned_path, :error_total_path, :error_owned_path

node :details do |presenter|
  presenter.all_statuses.map do |status|
    {
      label: presenter.labels.fetch(status, "Missing label for status #{status}"),
      global_status: presenter.global_statuses[status],
      total: presenter.total.fetch(status, 0),
      owned: presenter.owned.fetch(status, 0),
      total_path: presenter.total_paths[status],
      owned_path: presenter.owned_paths[status],
    }
  end
end
