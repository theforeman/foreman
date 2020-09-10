require 'test_helper'

class HostTokenTest < ActiveSupport::TestCase
  test "tokens should be removed based on build state" do
    disable_orchestration
    as_admin do
      h = FactoryBot.create(:host, :managed)
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
      org = FactoryBot.create :organization
      loc = FactoryBot.create :location
      template = FactoryBot.build :provisioning_template,
        :template_kind_name => 'PXELinux',
        :template => "<%= foreman_url('provision') %>",
        :organizations => [org], :locations => [loc]
      os = FactoryBot.create(:debian7_0, :with_associations, :with_os_defaults,
        :provisioning_templates => [template])
      FactoryBot.create :host, :managed, :build => true, :operatingsystem => os,
                                :organization => org, :location => loc
    end

    assert host.token.try(:value).present?
    assert_includes host.send(:generate_pxe_template, :PXELinux), "token=#{host.token.value}"
  end
end
