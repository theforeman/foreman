module Foreman::Model
  class EC2 < ComputeResource

    validates_presence_of :user, :password

    def self.model_name
      ComputeResource.model_name
    end

    def vm_instance_defaults
      {
        :flavor_id => "m1.small",
      }
    end

    def regions
     return [] if user.blank? or password.blank?
     @regions ||= client.describe_regions.body["regionInfo"].map{|r| r["regionName"]}
    end

    def test_connection
      super
      errors[:user].empty? and errors[:password] and regions
    rescue Fog::Compute::AWS::Error => e
      errors[:base] << e.message
    end

    def region= value
      self.url = value
    end

    def region
      @region ||= url.present? ? url : nil
    end

    private

    def client
      @client ||= ::Fog::Compute.new(:provider => "AWS", :aws_access_key_id => user, :aws_secret_access_key => password, :region => region)
    end

  end
end
