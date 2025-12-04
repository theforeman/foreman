require 'test_helper'

class TemplatesTest < ActiveSupport::TestCase
  setup do
    @host = FactoryBot.build(:host, :managed)
    @host.stubs(:skip_orchestration_for_testing?).returns(false)
    @queue = @host.queue
  end

  test 'without template' do
    @host.queue_render_checks
    assert_equal 0, @queue.count
  end

  test 'with valid provisioning template' do
    template = FactoryBot.build(:provisioning_template, template: "<%= @host.name %>")
    @host.stubs(:provisioning_template).returns(template)
    @host.queue_render_checks
    assert_equal 1, @queue.count
    assert @host.set_renderability
  end

  test 'with invalid provisioning template' do
    template = FactoryBot.build(:provisioning_template, template: "<%= I WILL RAISE AN ERROR( %>")
    @host.stubs(:provisioning_template).returns(template)
    @host.queue_render_checks
    assert_equal 1, @queue.count
    refute @host.set_renderability
  end

  test 'with transient host parameter' do
    template = FactoryBot.build :provisioning_template,
      name: 'fail_without_hp_parameter',
      template: "<% raise 'BOOOM' if host_param('transient-hp', '').empty? -%>"
    @host.stubs(:provisioning_template).returns(template)

    @host.queue_render_checks
    assert_equal 1, @queue.count
    refute @host.set_renderability

    @host.clear_host_parameters_cache!
    @host.host_parameters << FactoryBot.build(:host_parameter, name: 'transient-hp', value: 'i-am-not-saved-in-db')
    @host.queue_render_checks
    assert_equal 1, @queue.count
    assert @host.set_renderability
  end
end
