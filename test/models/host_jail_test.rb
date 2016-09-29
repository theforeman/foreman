require 'test_helper'

class HostJailTest < ActiveSupport::TestCase
  def test_jail_should_include_these_methods
    allowed = [:name, :diskLayout, :puppetmaster, :puppet_ca_server, :operatingsystem, :os, :environment, :ptable, :hostgroup,
               :organization, :url_for_boot, :params, :info, :hostgroup, :compute_resource, :domain, :ip, :mac, :shortname, :architecture,
               :model, :certname, :capabilities, :provider, :subnet, :token, :location, :organization, :provision_method, :image_build?,
               :pxe_build?, :otp, :realm, :param_true?, :param_false?, :nil?, :indent, :sp_name, :sp_ip, :sp_mac, :sp_subnet, :facts,
               :facts_hash, :bmc_nic]

    allowed.each do |m|
      assert Host::Managed::Jail.allowed?(m), "Method #{m} is not available in Host::Managed::Jail while should be allowed."
    end
  end
end
