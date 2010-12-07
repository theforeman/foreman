#!/usr/local/bin/ruby -w

$TESTING = true

require 'sexp_processor'
require 'stringio'
require 'minitest/autorun'
require 'pp'

# Fake test classes:

class TestProcessor < SexpProcessor # ZenTest SKIP
  attr_accessor :auto_shift_type

  def process_acc1(exp)
    out = self.expected.new(:acc2, exp.thing_three, exp.thing_two, exp.thing_one)
    exp.clear
    return out
  end

  def process_acc2(exp)
    out = []
    out << exp.thing_one
  end

  def process_specific(exp)
    name = exp.shift
    result = s(:blah)
    until exp.empty?
      result.push process(exp.shift)
    end
    result
  end

  def process_strip(exp)
    result = exp.deep_clone
    exp.clear
    result
  end

  def process_nonempty(exp)
    s(*exp)
  end

  def process_broken(exp)
    result = [*exp]
    exp.clear
    result
  end

  def process_expected(exp)
    exp.clear
    return {}
  end

  def process_string(exp)
    return exp.shift
  end

  def rewrite_rewritable(exp) # (a b c) => (a c b)
    return s(exp.shift, exp.pop, exp.shift)
  end

  def process_rewritable(exp)
    @n ||= 0
    exp.shift # name
    result = s(:rewritten)
    until exp.empty?
      result.push process(exp.shift)
    end
    result.push @n
    @n += 1
    result
  end

  def rewrite_major_rewrite(exp)
    exp[0] = :rewritable
    exp
  end
end

class TestProcessorDefault < SexpProcessor # ZenTest SKIP
  def initialize
    super
    self.default_method = :def_method
  end

  def def_method(exp)
    exp.clear
    self.expected.new(42)
  end
end

# Real test classes:

class TestSexpProcessor < MiniTest::Unit::TestCase

  def setup
    @processor = TestProcessor.new
  end

  def test_process_specific
    a = [:specific, [:x, 1], [:y, 2], [:z, 3]]
    expected = [:blah, [:x, 1], [:y, 2], [:z, 3]]
    assert_equal(expected, @processor.process(a))
  end

  def test_process_generic
    a = [:blah, 1, 2, 3]
    expected = a.deep_clone
    assert_equal(expected, @processor.process(a))
  end

  def test_process_default
    @processor = TestProcessorDefault.new
    @processor.warn_on_default = false

    a = s(:blah, 1, 2, 3)
    assert_equal(@processor.expected.new(42), @processor.process(a))
  end

  def test_process_not_sexp
    @processor = TestProcessor.new
    @processor.warn_on_default = false

    assert_raises SexpTypeError do
      @processor.process([:broken, 1, 2, 3])
    end
  end

  def test_process_unsupported_wrong
    @processor = TestProcessor.new
    @processor.unsupported << :strip

    assert_raises UnsupportedNodeError do
      @processor.process([:whatever])
    end
  end

  def test_unsupported_equal
    @processor.strict = true
    @processor.unsupported = [ :unsupported ]
    assert_raises UnsupportedNodeError do
      @processor.process([:unsupported, 42])
    end
  end

  def test_strict
    @processor.strict = true
    assert_raises UnknownNodeError do
      @processor.process([:blah, 1, 2, 3])
    end
  end
  def test_strict=; end #Handled

  def test_require_empty_false
    @processor.require_empty = false

    @processor.process([:nonempty, 1, 2, 3])
  end

  def test_require_empty_true
    assert_raises NotEmptyError do
      @processor.process([:nonempty, 1, 2, 3])
    end
  end
  def test_require_empty=; end # handled

  def test_process_strip
    @processor.auto_shift_type = true
    assert_equal([1, 2, 3], @processor.process(s(:strip, 1, 2, 3)))
  end

  def test_rewrite
    assert_equal(s(:rewritable, :b, :a),
                 @processor.rewrite(s(:rewritable, :a, :b)))
  end

  def test_rewrite_different_type
    assert_equal(s(:rewritable, :b, :a),
                 @processor.rewrite(s(:major_rewrite, :a, :b)))
  end

  def test_rewrite_deep
    assert_equal(s(:specific, s(:rewritable, :b, :a)),
                 @processor.rewrite(s(:specific, s(:rewritable, :a, :b))))
  end

  def test_rewrite_not_empty
    insert = s(:rewritable, 1, 2, 2)
    expect = s(:rewritable, 2, 1)
    result = @processor.rewrite(insert)
    assert_equal(expect, result)
    assert_equal(s(2), insert) # post-processing
  end

  def test_process_rewrite
    assert_equal(s(:rewritten, s(:y, 2), s(:x, 1), 0),
                 @processor.process(s(:rewritable, s(:x, 1), s(:y, 2))))
  end

  def test_process_rewrite_deep
    assert_equal(s(:blah, s(:rewritten, s(:b), s(:a), 0)),
                 @processor.process(s(:specific, s(:rewritable, s(:a), s(:b)))))
  end

  def test_rewrite_depth_first
    inn = s(:specific,
            s(:rewritable,
              s(:a),
              s(:rewritable,
                s(:rewritable, s(:b), s(:c)),
                s(:d))))
    out = s(:specific,
            s(:rewritable,
              s(:rewritable,
                s(:d),
                s(:rewritable, s(:c), s(:b))),
              s(:a)))

    assert_equal(out, @processor.rewrite(inn))
  end

  def test_process_rewrite_depth_first
    inn = s(:specific,
            s(:rewritable,
              s(:a),
              s(:rewritable,
                s(:rewritable, s(:b), s(:c)),
                s(:d))))
    out = s(:blah,
            s(:rewritten,
              s(:rewritten,
                s(:d),
                s(:rewritten, s(:c), s(:b), 0), 1),
              s(:a), 2))

    assert_equal(out, @processor.process(inn))
  end

  def test_assert_type_hit
    @processor.assert_type([:blah, 1, 2, 3], :blah)
  end

  def test_assert_type_miss
    assert_raises SexpTypeError do
      @processor.assert_type([:thingy, 1, 2, 3], :blah)
    end
  end

  def test_generate
    # nothing to test at this time... soon.
  end

  def test_auto_shift_type
    @processor.auto_shift_type = false
    assert_equal(false, @processor.auto_shift_type)
    @processor.auto_shift_type = true
    assert_equal(true, @processor.auto_shift_type)
  end
  def test_auto_shift_type_equal; end # handled

  def test_default_method
    # default functionality tested in process_default
    assert_nil @processor.default_method
    @processor.default_method = :something
    assert_equal :something, @processor.default_method
  end
  def test_default_method=; end # handled

  def test_expected
    assert_equal Sexp, @processor.expected
    assert_raises SexpTypeError do
      @processor.process([:expected])           # should raise
    end

    @processor.process(s(:str, "string"))       # shouldn't raise

    @processor.expected = Hash
    assert_equal Hash, @processor.expected
    assert !(Hash === s()), "Hash === s() should not be true"

    assert_raises SexpTypeError do
      @processor.process(s(:string, "string"))     # should raise
    end

    @processor.process([:expected])        # shouldn't raise
  end
  def test_expected=; end # handled

  # Not Testing:
  def test_debug; end
  def test_debug=; end
  def test_warn_on_default; end
  def test_warn_on_default=; end

end
