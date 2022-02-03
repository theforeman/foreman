glue(@facet) do
  attributes :uptime_seconds
end

child(@facet => :reported_data) do
  attributes :boot_time, :cores, :sockets, :disks_total
end
