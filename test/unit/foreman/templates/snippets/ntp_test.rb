require 'test_helper'

class NtpSnippetTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(host)
    @snippet ||= Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'ntp.erb').read

    source = OpenStruct.new(
      name: 'ntp',
      content: @snippet
    )

    scope = Foreman::Renderer::Scope::Provisioning.new(
      host: host,
      source: source
    )

    renderer.render(source, scope)
  end

  def ubuntu_host(major)
    operating_system = FactoryBot.create(:ubuntu22_04, :with_associations, major: major.to_s)
    host = FactoryBot.create(:host, :managed, :build => true, :operatingsystem => operating_system)
    FactoryBot.create(:host_parameter, host: host, name: 'ntp-server', value: 'ntp.example.com')
    host
  end

  setup do
    disable_orchestration
  end

  test 'configures systemd-timesyncd before Ubuntu 26' do
    result = render_template(ubuntu_host(24))

    assert_includes result, 'systemctl enable --now systemd-timesyncd'
    assert_includes result, 'timedatectl set-ntp true'
    refute_includes result, 'apt-get install -y chrony'
  end

  test 'configures chrony on Ubuntu 26' do
    result = render_template(ubuntu_host(26))

    assert_includes result, 'apt-get install -y chrony'
    assert_includes result, '/etc/chrony/chrony.conf'
    assert_includes result, 'systemctl enable --now chrony'
    refute_includes result, 'systemd-timesyncd'
  end
end
