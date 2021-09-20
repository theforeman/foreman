require 'test_helper'

module ForemanSalt
  class SaltFactImpoterTest < ActiveSupport::TestCase
    def setup
      @host = FactoryBot.build(:host)
      @facts = {
        _type: 'foreman_salt',
        a: 'b',
      }
    end

    test 'should have fact set' do
      importer = FactImporters::Base.new(@host, nil, @facts)
      assert_equal({ 'a' => 'b' }, importer.send(:facts))
    end

    test 'should have Salt as origin' do
      importer = FactImporters::Base.new(@host, nil, @facts)
      importer.stubs(:ensure_no_active_transaction).returns(true)
      importer.import!
      imported_fact = FactName.find_by_name('a')
      assert_equal 'a', imported_fact.name
      assert_equal 'Salt', imported_fact.origin
      assert_equal 'icons16x16/stub/black-s.png', imported_fact.icon_path
    end
  end
end
