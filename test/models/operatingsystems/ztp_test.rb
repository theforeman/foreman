require 'test_helper'

class ZTPTest < ActiveSupport::TestCase
  setup { disable_orchestration }

  test "Huawei ZTP parameter generation" do
    h = FactoryBot.create(:host, :managed, :with_environment, :domain => domains(:yourdomain),
          :interfaces => [FactoryBot.build(:nic_primary_and_provision,
            :ip => '2.3.4.10')],
          :architecture => architectures(:ASIC),
          :operatingsystem => operatingsystems(:vrp5),
          :pxe_loader => 'None',
          :compute_resource => compute_resources(:one),
          :medium => media(:vrp5),
          :puppet_proxy => smart_proxies(:puppetmaster),
          :ptable => FactoryBot.create(:ptable, :operatingsystem_ids => [operatingsystems(:vrp5).id])
    )
    medium_provider = Foreman::Plugin.medium_providers.find_provider h
    result = h.os.ztp_arguments h
    assert_equal(
      {
        :vendor => "huawei",
        :firmware => {
          :core => "ztp.cfg/images/#{medium_provider.unique_id}/firmware.cc",
          :web => "ztp.cfg/images/#{medium_provider.unique_id}/web.7z",
        },
      },
      result
    )
  end
end
