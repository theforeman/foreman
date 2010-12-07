require 'import'
import :rparsec
require 'benchmark'
require 'rubyunit'
class PerfTestCase < RUNIT::TestCase
  include Parsers
  include Functors
  def test1
    code = "1+#{'1+' * 6000}1"
    ops = OperatorTable.new do |tbl|
      tbl.infixl(char(?+) >> Plus, 20)
      tbl.infixl(char(?-) >> Minus, 20)
      tbl.infixl(char(?*) >> Mul, 40)
      tbl.infixl(char(?/) >> Div, 40)
      tbl.prefix(char(?-) >> Neg, 60)
    end
    expr = nil
    term = integer.map(&To_i) | char(?() >> lazy{expr} << char(?))
    delim = whitespace.many_
    expr = delim >> Expressions.build(term, ops, delim)
    Benchmark.bm do |x|
        x.report("parsing") {puts(expr.parse(code))}
    end
  end
end