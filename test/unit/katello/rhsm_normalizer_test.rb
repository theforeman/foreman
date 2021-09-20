require 'test_helper'

module Katello
  class NormalizerTest < ActiveSupport::TestCase
    def setup
      @separator = RhsmFactName::SEPARATOR
      @facts = {
        'interesting.key' => 'value_one',
        'another.interesting.key' => 'value_two',
        'just_key' => 'nothing',
      }
      @host = Host::Managed.new(name: "my.great.host", managed: false)
    end

    def test_normalizer_separator_change
      normalizer = FactImporters::Normalizers::Katello.new(@host, {})
      new_facts = normalizer.change_separator(@facts)

      assert_equal new_facts['interesting::key'], 'value_one'
      assert_equal new_facts['another::interesting::key'], 'value_two'
      assert_equal new_facts['just_key'], 'nothing'
    end
  end
end
