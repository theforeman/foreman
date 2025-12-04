require 'test_helper'

class HostParamsTest < ActiveSupport::TestCase
  test 'shows global params' do
    host = FactoryBot.build_stubbed(:host)

    FactoryBot.create(:common_parameter, :name => 'test_param1', :value => 'test_value1')

    assert_equal 'test_value1', host.host_params['test_param1']
  end

  test 'renders global params if template specified' do
    host = FactoryBot.build_stubbed(:host)
    # rubocop:disable Lint/InterpolationCheck
    FactoryBot.create(:common_parameter, :name => 'test_param1', :value => '<%= "test_value1-#{@host.name}" %>')
    # rubocop:enable Lint/InterpolationCheck

    assert_equal "test_value1-#{host.name}", host.host_params['test_param1']
  end

  test 'transient host parameters in host_params' do
    host = FactoryBot.build(:host)
    hp = FactoryBot.build(:host_parameter, name: 'transient-hp', value: 'i-am-not-saved-in-db')
    host.host_parameters << hp

    assert host.host_params.key? hp.name
    assert_equal hp.value, host.host_params[hp.name]

    assert host.host_params_hash.key? hp.name
    assert_equal hp.value, host.host_params_hash.dig(hp.name, :value)
  end

  test 'transient host params without :view_params permission' do
    user_role = FactoryBot.create(:user_user_role)

    as_user user_role.owner do
      host = FactoryBot.build(:host)
      hp = FactoryBot.build(:host_parameter, name: 'transient-hp', value: 'i-am-not-saved-in-db')
      host.host_parameters << hp

      refute host.host_params.key? hp.name
      assert host.host_params.key? parameters(:common).name

      refute host.host_params_hash.key? hp.name
      assert host.host_params_hash.key? parameters(:common).name
    end
  end
end
