# frozen_string_literal: true

require 'test_helper'

module ForemanAnsible
  # Tests for checking if FactSparser can sparse a hash and unsparse it
  class FactSparserTest < ActiveSupport::TestCase
    setup do
      @original_os_facts = { 'operatingsystem' => { 'major' => 20, 'minor' => 1,
                                                    'name' => 'Fedora' } }
      @sparsed_os_facts = { 'operatingsystem::major' => 20,
                            'operatingsystem::minor' => 1,
                            'operatingsystem::name' => 'Fedora' }
    end

    test 'sparses simple hash' do
      assert_equal @sparsed_os_facts,
        FactParsers::Utility::FactSparser.sparse(@original_os_facts)
    end

    test 'unsparse simple hash' do
      assert_equal @original_os_facts,
        FactParsers::Utility::FactSparser.unsparse(@sparsed_os_facts)
    end
  end
end
