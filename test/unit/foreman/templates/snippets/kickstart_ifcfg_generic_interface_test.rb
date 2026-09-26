require 'test_helper'

class KickstartIfcfgGenericInterfaceSnippetTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_snippet
    snippet_path = Rails.root.join(
      'app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'kickstart_ifcfg_generic_interface.erb'
    )
    source = OpenStruct.new(
      name: 'kickstart_ifcfg_generic_interface',
      content: File.read(snippet_path)
    )
    scope = Class.new(Foreman::Renderer::Scope::Provisioning).send(
      :new,
      host: @host,
      source: source,
      variables: {
        interface: @interface,
        dhcp: false,
        subnet: @subnet,
        subnet6: @subnet6,
        attached_to_bond: false,
        bonding_interfaces: [],
      })

    renderer.render(source, scope)
  end

  setup do
    @subnet = FactoryBot.build(:subnet_ipv4_static_for_snapshots)
    @subnet6 = FactoryBot.build(:subnet_ipv6_static_for_snapshots)
    @interface = FactoryBot.build(:nic_for_snapshots,
      :with_v4_static,
      :with_v6_static,
      :subnet => @subnet,
      :subnet6 => @subnet6)
    @host = FactoryBot.build(:host_for_snapshots, :with_rhel9, :interfaces => [@interface])
  end

  test 'includes IPv4 and IPv6 DNS servers for a dual-stack interface' do
    result = render_snippet

    assert_includes result, 'DNS1="192.168.42.2"'
    assert_includes result, 'DNS2="192.168.42.3"'
    assert_includes result, 'DNS3="2001:db8:42::8"'
    assert_includes result, 'DNS4="2001:db8:42::4"'
  end
end
