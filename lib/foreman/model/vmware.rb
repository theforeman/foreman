module Foreman::Model
  class Vmware < ComputeResource

    validates_presence_of :user, :password, :server

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:build, :image]
    end

    #FIXME
    def max_cpu_count
      8
    end

    def max_memory
      16*1024*1024*1024
    end

    def datacenters
      client.datacenters
    end

    def test_connection
      super
      errors[:server] and errors[:user].empty? and errors[:password] and datacenters
    rescue => e
      errors[:base] << e.message
    end

    def server
      url
    end

    def server= value
      self.url = value
    end

    def console uuid
      vm = find_vm_by_uuid(uuid)
      raise "VM is not running!" unless vm.ready?
      #TOOD port, password
      #NOTE this requires the following port to be open on your ESXi FW
      values = {:port => unused_vnc_port(vm.hypervisor), :password => random_password, :enabled => true}
      vm.config_vnc(values)
      VNCProxy.start :host => vm.hypervisor, :host_port => values[:port], :password => values[:password]
    end

    private

    def client
      @client ||= ::Fog::Compute.new(
        :provider                     => "vsphere",
        :vsphere_username             => user,
        :vsphere_password             => password,
        :vsphere_server               => server
      )
    end

    def unused_vnc_port ip
      10.times do
        port = 5901 + rand(64)
        unused = (TCPSocket.connect(ip, port).close rescue true)
        return port if unused
      end
      raise "no unused port found"
    end

  end
end
