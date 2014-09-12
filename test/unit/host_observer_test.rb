require 'test_helper'

class HostObserverTest < ActiveSupport::TestCase
  test "tokens should be removed based on build state" do
    disable_orchestration
    h = FactoryGirl.create(:host, :managed)
    as_admin do
      Setting[:token_duration] = 60
      assert_difference('Token.count') do
        h.build = true
        h.save!
      end
      assert_difference('Token.count', -1) do
        h.build = false
        h.save!
      end
    end
  end

  test "pxe template should have a token when created" do
    disable_orchestration
    host = as_admin do
      Setting[:token_duration] = 30
      host = Host.create! :name => "foo", :mac => "aabbeeddccff", :ip => "2.3.4.244", :managed => true, :ptable => ptables(:one), :medium => media(:one),
        :build => true, :architecture => architectures(:x86_64), :environment => Environment.first, :puppet_proxy_id => smart_proxies(:one).id,
        :domain => Domain.first, :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one),
        :root_pass => "xybxa6JUkz63w", :url_options => {:host => 'foreman', :protocol => "http://"},
        :location => taxonomies(:location1), :organization => taxonomies(:organization1)
    end

    assert host.token.try(:value).present?

    assert host.send(:generate_pxe_template)["token=#{host.token.value}"]
  end

end
