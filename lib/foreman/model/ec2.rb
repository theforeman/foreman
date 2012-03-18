module Foreman::Model
  class EC2 < ComputeResource

    def self.model_name
      ComputeResource.model_name
    end

    def vm_instance_defaults
      {
        :flavor_id => "m1.small",
      }
    end

    private

    def host
      URI.parse(url).host
    end

    def client
      @client ||= ::Fog::Compute.new(:provider => "AWS", :aws_access_key_id => user, :aws_secret_access_key => password, :host => host)
    end

  end
end
