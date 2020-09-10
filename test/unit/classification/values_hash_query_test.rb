require "test_helper"

module Classification
  class ValuesHashQueryTest < ActiveSupport::TestCase
    let(:lookup_key) { FactoryBot.create(:lookup_key, path: "compute_resource,hostgroup\nhostgroup\nfqdn") }

    describe '#sort_lookup_values' do
      it 'sort values according to a value length for members of MATCHERS_INHERITANCE' do
        lookup_values = [stub(lookup_key: lookup_key, match: 'hostgroup=Common,organization=Org', value: 'a'),
                         stub(lookup_key: lookup_key, match: 'hostgroup=Common/ChildGroup,organization=Org', value: 'b')]
        lookup_values_cache = stub(select: lookup_values)
        Classification::ValuesHashQuery.stubs(:lookup_values).returns(lookup_values_cache)
        values = Classification::ValuesHashQuery.values_hash(mock('host'), [lookup_key])
        assert_equal 'b', values[lookup_key]
      end
    end
  end
end
