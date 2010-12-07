require 'import'
require 'runit/testcase'
import :parsers, :functors

include RParsec
class Proc
  include FunctorMixin
end
class Method
  include FunctorMixin
end
    
class FunctorTestCase < RUNIT::TestCase
  include Functors
  def verify(expected, f, *args)
    assert_equal(expected, f.call(*args))
  end
  def testConst
    verify(1, const(1), 'a')
  end
  def testMethod
    verify(true, 1.method(:kind_of?), Fixnum)
  end
  def testFlip
    verify(1, Minus.flip, 1, 2)
  end
  def testCompose
    verify(-3, Neg.compose(Plus), 1, 2)
    verify(-3, Neg << Plus, 1, 2)
    verify(-3, Plus >> Neg, 1, 2)
    verify(3, Neg << Neg << Plus, 1, 2)
  end
  def testCurry
    assert_equal(3, Plus.curry.call(1).call(2))
    assert_equal(-1, Minus.curry.call(1).call(2))
  end
  def testReverse_curry
    assert_equal(1, Minus.reverse_curry.call(1).call(2))
  end
  def testUncurry
    verify(-1, Minus.curry.uncurry, 1, 2)
  end
  def testReverse_uncurry
    verify(-1, Minus.reverse_curry.reverse_uncurry, 1, 2)
    verify(1, Minus.reverse_curry.uncurry, 1, 2)
    verify(1, Minus.curry.reverse_uncurry, 1, 2)
  end
  def testRepeat
    cnt=0
    inc = proc {cnt+=1}
    n = 10
    verify(n, (inc*n))
    assert_equal(10, cnt)
  end
  def testPower
    double = Mul.curry.call(2)
    verify(8, double ** 3, 1)
    verify(nil, double ** 0, 1)
  end
  def testNth
    verify(2, nth(1), 1, 2, 3)
  end
  def testMethodIsMixedIn
    verify(false, 1.method(:kind_of?).compose(Id), String)
  end
end