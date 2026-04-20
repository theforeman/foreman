require 'test_helper'

class HostLookupValueAccessControlTest < ActiveSupport::TestCase
  test 'nested lookup_values_attributes cannot retarget existing override match to another host' do
    host_source = FactoryBot.create(:host)
    host_destination = FactoryBot.create(:host)
    source_match = host_source.lookup_value_match
    destination_match = host_destination.lookup_value_match

    refute_equal source_match, destination_match, 'fixture hosts must resolve to different fqdn matchers'

    lkey = FactoryBot.create(:lookup_key, :integer, override: true, path: 'fqdn')

    as_admin do
      assert_difference('LookupValue.count', 1) do
        assert host_source.update!(
          lookup_values_attributes: { '0' => { lookup_key_id: lkey.id, value: 111 } }
        )
      end

      lvalue = host_source.lookup_values.first
      assert_equal source_match, lvalue.match

      assert host_source.update!(
        lookup_values_attributes: {
          '0' => {
            id: lvalue.id,
            match: destination_match,
            value: 999,
          },
        }
      )
    end

    lvalue = host_source.lookup_values.first.reload
    assert_equal source_match, lvalue.match,
      'nested host update cannot retarget lookup value match to another host - broken access control'
    assert_equal 999, lvalue.value
  end
end
