glue(@facet) do
  attributes :uptime_seconds
end

child(@facet => :reported_data) do
  attributes :boot_time, :cores, :sockets, :ram, :disks_total, :kernel_version, :bios_vendor, :bios_release_date, :bios_version
end
