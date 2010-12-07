require 'rubygems'
require 'minitest/autorun'
require 'ruby_parser_extras'

class TestStackState < MiniTest::Unit::TestCase
  def test_stack_state
    s = StackState.new :test
    s.push true
    s.push false
    s.lexpop
    assert_equal [false, true], s.stack
  end

  def test_is_in_state
    s = StackState.new :test
    assert_equal false, s.is_in_state
    s.push false
    assert_equal false, s.is_in_state
    s.push true
    assert_equal true, s.is_in_state
    s.push false
    assert_equal false, s.is_in_state
  end

  def test_lexpop
    s = StackState.new :test
    assert_equal [false], s.stack
    s.push true
    s.push false
    assert_equal [false, true, false], s.stack
    s.lexpop
    assert_equal [false, true], s.stack
  end

  def test_pop
    s = StackState.new :test
    assert_equal [false], s.stack
    s.push true
    assert_equal [false, true], s.stack
    assert_equal true, s.pop
    assert_equal [false], s.stack
  end

  def test_push
    s = StackState.new :test
    assert_equal [false], s.stack
    s.push true
    s.push false
    assert_equal [false, true, false], s.stack
  end
end

class TestEnvironment < MiniTest::Unit::TestCase
  def deny t
    assert ! t
  end

  def setup
    @env = Environment.new
    @env[:blah] = 42
    assert_equal 42, @env[:blah]
  end

  def test_use
    @env.use :blah
    expected = [{ :blah => true }]
    assert_equal expected, @env.instance_variable_get(:"@use")
  end

  def test_use_scoped
    @env.use :blah
    @env.extend
    expected = [{}, { :blah => true }]
    assert_equal expected, @env.instance_variable_get(:"@use")
  end

  def test_used_eh
    @env.extend :dynamic
    @env[:x] = :dvar
    @env.use :x
    assert_equal true, @env.used?(:x)
  end

  def test_used_eh_none
    assert_equal nil, @env.used?(:x)
  end

  def test_used_eh_scoped
    self.test_used_eh
    @env.extend :dynamic
    assert_equal true, @env.used?(:x)
  end

  def test_var_scope_dynamic
    @env.extend :dynamic
    assert_equal 42, @env[:blah]
    @env.unextend
    assert_equal 42, @env[:blah]
  end

  def test_var_scope_static
    @env.extend
    assert_equal nil, @env[:blah]
    @env.unextend
    assert_equal 42, @env[:blah]
  end

  def test_dynamic
    expected1 = {}
    expected2 = { :x => 42 }

    assert_equal expected1, @env.dynamic
    begin
      @env.extend :dynamic
      assert_equal expected1, @env.dynamic

      @env[:x] = 42
      assert_equal expected2, @env.dynamic

      begin
        @env.extend :dynamic
        assert_equal expected2, @env.dynamic
        @env.unextend
      end

      assert_equal expected2, @env.dynamic
      @env.unextend
    end
    assert_equal expected1, @env.dynamic
  end

  def test_all_dynamic
    expected = { :blah => 42 }

    @env.extend :dynamic
    assert_equal expected, @env.all
    @env.unextend
    assert_equal expected, @env.all
  end

  def test_all_static
    @env.extend
    expected = { }
    assert_equal expected, @env.all

    @env.unextend
    expected = { :blah => 42 }
    assert_equal expected, @env.all
  end

  def test_dynamic_eh
    assert_equal false, @env.dynamic?
    @env.extend :dynamic
    assert_equal true, @env.dynamic?
    @env.extend
    assert_equal false, @env.dynamic?
  end

  def test_all_static_deeper
    expected0 = { :blah => 42 }
    expected1 = { :blah => 42, :blah2 => 24 }
    expected2 = { :blah => 27 }

    @env.extend :dynamic
    @env[:blah2] = 24
    assert_equal expected1, @env.all

    @env.extend 
    @env[:blah] = 27
    assert_equal expected2, @env.all

    @env.unextend
    assert_equal expected1, @env.all

    @env.unextend
    assert_equal expected0, @env.all
  end
end
