require 'test_helper'

class NameGeneratorTest < ActionMailer::TestCase
  def setup
    Rails.cache.stubs(:write)
    Deacon::RandomGenerator.stubs(:random_initial_seed).returns(1)
  end

  def test_mac_for_empty
    NameGenerator.expects(:mac_based?).returns(true)
    assert_equal '', NameGenerator.new.next_mac_name('')
  end

  def test_mac_name
    NameGenerator.expects(:mac_based?).returns(true)
    assert_equal "derek-levi-pratico-cedillo", NameGenerator.new.next_mac_name("00:00:ca:fe:01:01")
  end

  def test_random_name_once
    NameGenerator.expects(:random_based?).returns(true)
    Rails.cache.expects(:write).with("name_generator_register", 1)
    assert_equal "velma-pratico", NameGenerator.new.next_random_name
  end

  def test_random_register_is_stored_in_rails_cache
    NameGenerator.stubs(:random_based?).returns(true)
    @generator = NameGenerator.new
    Rails.cache.expects(:write).with("name_generator_register", 16777216)
    @generator.next_random_name
    Rails.cache.expects(:fetch).with("name_generator_register").returns(16777216).at_least(2)
    assert_equal 16777216, @generator.register
    assert_equal "angie-warmbrod", @generator.next_random_name
  end
end
