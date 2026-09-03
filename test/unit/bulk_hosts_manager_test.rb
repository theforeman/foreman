require 'test_helper'

class BulkHostsManagerTest < ActiveSupport::TestCase
  setup do
    as_admin do
      @host1 = FactoryBot.create(:host, :managed)
      @host2 = FactoryBot.create(:host, :managed)
      @host1.host_parameters.create!(:name => 'p1', :value => 'old')
      @host2.host_parameters.create!(:name => 'other', :value => 'keep')
    end
  end

  test "update_parameters updates existing host parameters and creates missing overrides" do
    result = BulkHostsManager.new(hosts: [@host1, @host2]).update_parameters(name: 'p1', value: 'hello')

    assert_equal 2, result[:updated_count]
    assert_empty result[:failed_host_ids]
    assert_equal 'hello', @host1.reload.host_parameters.find_by(:name => 'p1').value
    assert_equal 'hello', @host2.reload.host_parameters.find_by(:name => 'p1').value
    assert_equal 'keep', @host2.host_parameters.find_by(:name => 'other').value
  end

  test "update_parameters copies type and hidden flag from a matching global parameter" do
    as_admin do
      FactoryBot.create(:common_parameter, :name => 'p1', :value => '1', :key_type => 'integer', :hidden_value => true)
    end

    result = BulkHostsManager.new(hosts: [@host2]).update_parameters(name: 'p1', value: '5')

    assert_equal 1, result[:updated_count]
    override = @host2.reload.host_parameters.find_by(:name => 'p1')
    assert_equal 5, override.value
    assert_equal 'integer', override.key_type
    assert override.hidden_value?
  end
end
