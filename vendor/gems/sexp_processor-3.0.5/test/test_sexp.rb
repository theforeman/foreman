#!/usr/local/bin/ruby -w

$TESTING = true

require 'minitest/autorun'
require 'sexp_processor'
require 'stringio'
require 'pp'

class SexpTestCase < MiniTest::Unit::TestCase
  # KEY for regex tests
  # :a == no change
  # :b == will change (but sometimes ONLY once)
  # :c == change to

  include SexpMatchSpecials

  def util_equals(x, y)
    result = x == y
    refute_nil result, "#{x.inspect} does not === #{y.inspect}"
  end

  def util_equals3(x, y)
    result = x === y
    refute_nil result, "#{x.inspect} does not === #{y.inspect}"
  end

  def setup
    @any = ANY()
  end

  def test_stupid
    # shuts up test/unit
  end
end

class TestSexp < SexpTestCase # ZenTest FULL

  class SexpFor
    def method
      1
    end
  end

  def util_pretty_print(expect, input)
    io = StringIO.new
    PP.pp(input, io)
    io.rewind
    assert_equal(expect, io.read.chomp)
  end

  def setup
    super
    @sexp_class = Object.const_get(self.class.name[4..-1])
    @processor = SexpProcessor.new
    @sexp = @sexp_class.new(1, 2, 3)
    @basic_sexp = s(:lasgn, :var, s(:lit, 42))
    @re = s(:lit, 42)
    @bad1 = s(:lit, 24)
    @bad1 = s(:blah, 42)
  end

  def test_class_from_array
#    raise NotImplementedError, 'Need to write test_class_from_array'
  end

  def test_class_index
#    raise NotImplementedError, 'Need to write test_class_index'
  end

  def test_array_type_eh
    assert_equal false, @sexp.array_type?
    @sexp.unshift :array
    assert_equal true, @sexp.array_type?
  end

  def test_each_of_type
    # TODO: huh... this tests fails if top level sexp :b is removed
    @sexp = s(:b, s(:a, s(:b, s(:a), :a, s(:b, :a), s(:b, s(:a)))))
    count = 0
    @sexp.each_of_type(:a) do |exp|
      count += 1
    end
    assert_equal(3, count, "must find 3 a's in #{@sexp.inspect}")
  end

  def test_equals2_array
    # can't use assert_equals because it uses array as receiver
    refute_equal(@sexp, [1, 2, 3],
                 "Sexp must not be equal to equivalent array")
    # both directions just in case
    # HACK - this seems to be a bug in ruby as far as I'm concerned
    # assert_not_equal([1, 2, 3], @sexp,
    #   "Sexp must not be equal to equivalent array")
  end

  def test_equals2_not_body
    sexp2 = s(1, 2, 5)
    refute_equal(@sexp, sexp2)
  end

  def test_equals2_sexp
    sexp2 = s(1, 2, 3)
    unless @sexp.class == Sexp then
      refute_equal(@sexp, sexp2)
    end
  end

  def test_equals3_any
    util_equals3 @any, s()
    util_equals3 @any, s(:a)
    util_equals3 @any, s(:a, :b, s(:c))
  end

  def test_equals3_full_match
    util_equals3 s(), s()             # 0
    util_equals3 s(:blah), s(:blah)   # 1
    util_equals3 s(:a, :b), s(:a, :b) # 2
    util_equals3 @basic_sexp, @basic_sexp.dup     # deeper structure
  end

  def test_equals3_mismatch
    assert_nil s() === s(:a)
    assert_nil s(:a) === s()
    assert_nil s(:blah1) === s(:blah2)
    assert_nil s(:a) === s(:a, :b)
    assert_nil s(:a, :b) === s(:a)
    assert_nil s(:a1, :b) === s(:a2, :b)
    assert_nil s(:a, :b1) === s(:a, :b2)
    assert_nil @basic_sexp === @basic_sexp.dup.push(42)
    assert_nil @basic_sexp.dup.push(42) === @basic_sexp
  end

  def test_equals3_subset_match
    util_equals3 s(:a), s(s(:a), s(:b))                 # left
    util_equals3 s(:a), s(:blah, s(:a   ), s(:b))       # mid 1
    util_equals3 s(:a, 1), s(:blah, s(:a, 1), s(:b))    # mid 2
    util_equals3 @basic_sexp, s(:blah, @basic_sexp.dup, s(:b))      # mid deeper
    util_equals3 @basic_sexp, s(@basic_sexp.dup, s(:a), s(:b))      # left deeper

    util_equals3 s(:a), s(:blah, s(:blah, s(:a)))       # left deeper
  end

#   def test_equalstilde_any
#     result = @basic_sexp =~ s(:lit, ANY())
#     p result
#     assert result
#   end

  def test_equalstilde_fancy
    assert_nil s(:b) =~ s(:a, s(:b), :c)
    refute_nil s(:a, s(:b), :c) =~ s(:b)
  end

  def test_equalstilde_plain
    result = @basic_sexp =~ @re
    assert result
  end

  def test_find_and_replace_all
    @sexp    = s(:a, s(:b, s(:a), s(:b), s(:b, s(:a))))
    expected = s(:a, s(:a, s(:a), s(:a), s(:a, s(:a))))

    @sexp.find_and_replace_all(:b, :a)

    assert_equal(expected, @sexp)
  end

  def test_gsub
    assert_equal s(:c), s().gsub(s(), s(:c))
    assert_equal s(:c), s(:b).gsub(s(:b), s(:c))
    assert_equal s(:a), s(:a).gsub(s(:b), s(:c))
    assert_equal s(:a, s(:c)), s(:a, s(:b)).gsub(s(:b), s(:c))

    assert_equal(s(:a, s(:c), s(:c)),
                 s(:a, s(:b), s(:b)).gsub(s(:b), s(:c)))
    assert_equal(s(:a, s(:c), s(:a, s(:c))),
                 s(:a, s(:b), s(:a, s(:b))).gsub(s(:b), s(:c)))
  end

  def test_inspect
    k = @sexp_class
    n = k.name[0].chr.downcase
    assert_equal("#{n}()",
                 k.new().inspect)
    assert_equal("#{n}(:a)",
                 k.new(:a).inspect)
    assert_equal("#{n}(:a, :b)",
                 k.new(:a, :b).inspect)
    assert_equal("#{n}(:a, #{n}(:b))",
                 k.new(:a, k.new(:b)).inspect)
  end

  def test_mass
    assert_equal 1, s(:a).mass
    assert_equal 3, s(:a, s(:b), s(:c)).mass

    s = s(:iter,
          s(:call, nil, :a, s(:arglist, s(:lit, 1))),
          s(:lasgn, :c),
          s(:call, nil, :d, s(:arglist)))

    assert_equal 7, s.mass
  end

  def test_method_missing
    assert_nil @sexp.not_there
    assert_equal s(:lit, 42), @basic_sexp.lit
  end

  def test_method_missing_ambigious
    assert_raises NoMethodError do
      pirate = s(:says, s(:arrr!), s(:arrr!), s(:arrr!))
      pirate.arrr!
    end
  end

  def test_method_missing_deep
    sexp = s(:blah, s(:a, s(:b, s(:c, :yay!))))
    assert_equal(s(:c, :yay!), sexp.a.b.c)
  end

  def test_method_missing_delete
    sexp = s(:blah, s(:a, s(:b, s(:c, :yay!))))

    assert_equal(s(:c, :yay!), sexp.a.b.c(true))
    assert_equal(s(:blah, s(:a, s(:b))), sexp)
  end

  def test_pretty_print
    util_pretty_print("s()",
                       s())
    util_pretty_print("s(:a)",
                       s(:a))
    util_pretty_print("s(:a, :b)",
                       s(:a, :b))
    util_pretty_print("s(:a, s(:b))",
                       s(:a, s(:b)))
  end

  def test_sexp_body
    assert_equal [2, 3], @sexp.sexp_body
  end

  def test_shift
    assert_equal(1, @sexp.shift)
    assert_equal(2, @sexp.shift)
    assert_equal(3, @sexp.shift)

    assert_raises(RuntimeError) do
      @sexp.shift
    end
  end

  def test_structure
    @sexp    = s(:a, 1, 2, s(:b, 3, 4), 5, 6)
    backup = @sexp.deep_clone
    expected = s(:a, s(:b))

    assert_equal(expected, @sexp.structure)
    assert_equal(backup, @sexp)
  end

  def test_sub
    assert_equal s(:c), s().sub(s(), s(:c))
    assert_equal s(:c), s(:b).sub(s(:b), s(:c))
    assert_equal s(:a), s(:a).sub(s(:b), s(:c))
    assert_equal s(:a, s(:c)), s(:a, s(:c)).sub(s(:b), s(:c))

    assert_equal s(:a, s(:c), s(:b)), s(:a, s(:b), s(:b)).sub(s(:b), s(:c))

    assert_equal(s(:a, s(:c), s(:a)),
                 s(:a, s(:b), s(:a)).sub(s(:b), s(:c)))
    assert_equal(s(:a, s(:c), s(:a, s(:a))),
                 s(:a, s(:b), s(:a, s(:a))).sub(s(:b), s(:c)))
    assert_equal(s(:a, s(:a), s(:a, s(:c), s(:b))),
                 s(:a, s(:a), s(:a, s(:b), s(:b))).sub(s(:b), s(:c)))
    assert_equal(s(:a, s(:c, s(:b))),
                 s(:a, s(:b)).sub(s(:b), s(:c, s(:b))))
  end

  def test_to_a
    assert_equal([1, 2, 3], @sexp.to_a)
  end

  def test_to_s
    test_inspect
  end
end

class TestSexpAny < SexpTestCase

  def setup
    super
  end

  def test_equals
    util_equals @any, s()
    util_equals @any, s(:a)
    util_equals @any, s(:a, :b, s(:c))
  end

  def test_equals3
    util_equals3 @any, s()
    util_equals3 @any, s(:a)
    util_equals3 @any, s(:a, :b, s(:c))
  end

end
