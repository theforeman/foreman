module Net::DHCP
  class SparcRecord < Record
    attr_accessor :vendor, :root_path_name, :sysid_server_path,
      :install_server_name, :install_server_ip, :jumpstart_server_path,
      :root_server_hostname, :root_server_ip, :install_path

    def initialize(opts = { })
      super(opts)
      raise "Must define a dhcp vendor" if vendor.blank?
    end

    def attrs
      @attrs ||= super.merge(
        { "#{vendor}root_path_name"        => root_path_name,
          "#{vendor}sysid_server_path"     => sysid_server_path,
          "#{vendor}install_server_ip"     => install_server_ip,
          "#{vendor}jumpstart_server_path" => jumpstart_server_path,
          "#{vendor}install_server_name"   => install_server_name,
          "#{vendor}root_server_hostname"  => root_server_hostname,
          "#{vendor}root_server_ip"        => root_server_ip,
          "#{vendor}install_path"          => install_path,
        }).compact
    end
  end
end
