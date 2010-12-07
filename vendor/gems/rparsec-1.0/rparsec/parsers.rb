require 'rparsec/parser'

module RParsec

class FailureParser < Parser
  init :msg
  def _parse ctxt
    return ctxt.failure(@msg)
  end
end

class ValueParser < Parser
  init :value
  def _parse ctxt
    ctxt.retn @value
  end
end

class LazyParser < Parser
  init :block
  def _parse ctxt
    @block.call._parse ctxt
  end
end

class Failures
  def self.add_error(err, e)
    return e if err.nil?
    return err if e.nil?
    cmp = compare_error(err, e)
    return err if cmp > 0
    return e if cmp < 0
    err
    # merge_error(err, e)
  end
  
  private
  
  def self.get_first_element(err)
    while err.kind_of?(Array)
      err = err[0]
    end
    err
  end

  def self.compare_error(e1, e2)
    e1, e2 = get_first_element(e1), get_first_element(e2)
    return -1 if e1.index < e2.index
    return 1 if e1.index > e2.index
    0
  end
end

###############################################
#def merge_error(e1, e2)
#  return e1 << e2 if e1.kind_of?(Array)
#  [e1,e2]
#end
###############################################
class ThrowParser < Parser
  init :symbol
  def _parse ctxt
    throw @symbol
  end
end

class CatchParser < Parser
  init :symbol, :parser
  def _parse ctxt
    interrupted = true
    ok = false
    catch @symbol do
      ok = @parser._parse(ctxt)
      interrupted = false
    end
    return ctxt.retn(@symbol) if interrupted
    ok
  end
end

class PeekParser < Parser
  init :parser
  def _parse ctxt
    ind = ctxt.index
    return false unless @parser._parse ctxt
    ctxt.index = ind
    return true
  end
  def peek
    self
  end
end

class AtomParser < Parser
  init :parser
  def _parse ctxt
    ind = ctxt.index
    return true if @parser._parse ctxt
    ctxt.index = ind
    return false
  end
  def atomize
    self
  end
end

class LookAheadSensitiveParser < Parser
  def initialize(la=1)
    super()
    @lookahead = la
  end
  def visible(ctxt, n)
    ctxt.index - n < @lookahead
  end
  def lookahead(n)
    raise ArgumentError, "lookahead number #{n} should be positive" unless n>0
    return self if n == @lookahead
    withLookahead(n)
  end
  def not(msg="#{self} unexpected")
    NotParser.new(self, msg, @lookahead)
  end
end

class NotParser < LookAheadSensitiveParser
  def initialize(parser, msg, la=1)
    super(la)
    @parser, @msg, @name = parser, msg, "~#{parser.name}"
  end
  def _parse ctxt
    ind = ctxt.index
    if @parser._parse ctxt
      ctxt.index = ind
      return ctxt.expecting(@msg)
    end
    return ctxt.retn(nil) if visible(ctxt, ind)
    return false
  end
  def withLookahead(n)
    NotParser.new(@parser, @msg, n)
  end
  def not()
    @parser
  end
end

class ExpectParser < Parser
  def initialize(parser, msg)
    super()
    @parser, @msg, @name = parser, msg, msg
  end
  def _parse ctxt
    ind = ctxt.index
    return true if @parser._parse ctxt
    return false unless ind == ctxt.index
    ctxt.expecting(@msg)
  end
end

class PlusParser < LookAheadSensitiveParser
  def initialize(alts, la=1)
    super(la)
    @alts = alts
  end
  def _parse ctxt
    ind, result, err = ctxt.index, ctxt.result, ctxt.error
    for p in @alts
      ctxt.reset_error
      ctxt.index, ctxt.result = ind, result
      return true if p._parse(ctxt)
      return false unless visible(ctxt, ind)
      err = Failures.add_error(err, ctxt.error)
    end
    ctxt.error = err
    return false
  end
  def withLookahead(n)
    PlusParser.new(@alts, n)
  end
  def plus other
    PlusParser.new(@alts.dup << other, @lookahead).setName(name)
  end
  def_sig :plus, Parser
end


class AltParser < LookAheadSensitiveParser
  def initialize(alts, la = 1)
    super(la)
    @alts, @lookahead = alts, la
  end
  def _parse ctxt
    ind, result, err = ctxt.index, ctxt.result, ctxt.error
    err_ind, err_pos = -1, -1
    for p in @alts
      ctxt.reset_error
      ctxt.index, ctxt.result = ind, result
      return true if p._parse(ctxt)
      if ctxt.error.index > err_pos
        err, err_ind, err_pos = ctxt.error, ctxt.index, ctxt.error.index
      end
    end
    ctxt.index, ctxt.error = err_ind, err
    return false
  end
  def withLookahead(n)
    AltParser.new(@alts, n)
  end
  def | other
    AltParser.new(@alts.dup << autobox_parser(other)).setName(name)
  end
end


class BestParser < Parser
  init :alts, :longer
  def _parse ctxt
    best_result, best_ind = nil, -1
    err_ind, err_pos = -1, -1
    ind, result, err = ctxt.index, ctxt.result, ctxt.error
    for p in @alts
      ctxt.reset_error
      ctxt.index, ctxt.result = ind, result
      if p._parse(ctxt)
        err, now_ind = nil, ctxt.index
        if best_ind==-1 || now_ind != best_ind && @longer == (now_ind>best_ind)
          best_result, best_ind = ctxt.result, now_ind
        end
      elsif best_ind < 0 # no good match found yet.
        if ctxt.error.index > err_pos
          err_ind, err_pos = ctxt.index, ctxt.error.index
        end
        err = Failures.add_error(err, ctxt.error)
      end
    end
    if best_ind >= 0
      ctxt.index = best_ind
      return ctxt.retn(best_result)
    else
      ctxt.error, ctxt.index = err, err_ind
      return false
    end
  end
end

class BoundParser < Parser
  init :parser, :proc
  def _parse ctxt
    return false unless @parser._parse(ctxt)
    @proc.call(ctxt.result)._parse ctxt
  end
end

class BoundnParser < Parser
  init :parser, :proc
  def _parse ctxt
    return false unless @parser._parse(ctxt)
    @proc.call(*ctxt.result)._parse ctxt
  end
end

class MapParser < Parser
  init :parser, :proc
  def _parse ctxt
    return false unless @parser._parse(ctxt)
    ctxt.result = @proc.call(ctxt.result)
    true
  end
end

class MapnParser < Parser
  init :parser, :proc
  def _parse ctxt
    return false unless @parser._parse(ctxt)
    ctxt.result = @proc.call(*ctxt.result)
    true
  end
end

class SequenceParser < Parser
  init :parsers, :proc
  def _parse ctxt
    if @proc.nil?
      for p in @parsers
        return false unless p._parse(ctxt)
      end
    else
      results = []
      for p in @parsers
        return false unless p._parse(ctxt)
        results << ctxt.result
      end
      ctxt.retn(@proc.call(*results))
    end
    return true
  end
  def seq(other, &block)
    # TypeChecker.check_arg_type Parser, other, :seq
    SequenceParser.new(@parsers.dup << other, &block)
  end
  def_sig :seq, Parser
end

class FollowedParser < Parser
  init :p1, :p2
  def _parse ctxt
    return false unless @p1._parse ctxt
    result = ctxt.result
    return false unless @p2._parse ctxt
    ctxt.retn(result)
  end
end

class SatisfiesParser < Parser
  init :pred, :expected
  def _parse ctxt
    elem = nil
    if ctxt.eof || !@pred.call(elem=ctxt.current)
      return ctxt.expecting(@expected)
    end
    ctxt.next
    ctxt.retn elem
  end
end

class AnyParser < Parser
  def _parse ctxt
    return ctxt.expecting if ctxt.eof
    result = ctxt.current
    ctxt.next
    ctxt.retn result
  end
end

class EofParser < Parser
  init :msg
  def _parse ctxt
    return true if ctxt.eof
    return ctxt.expecting(@msg)
  end
end

class RegexpParser < Parser
  init :ptn, :msg
  def _parse ctxt
    scanner = ctxt.scanner
    result = scanner.check @ptn
    if result.nil?
      ctxt.expecting(@msg)
    else
      ctxt.advance(scanner.matched_size)
      ctxt.retn(result)
    end
  end
end

class AreParser < Parser
  init :vals, :msg
  def _parse ctxt
    if @vals.length > ctxt.available
      return ctxt.expecting(@msg)
    end
    cur = 0
    for cur in (0...@vals.length)
      if @vals[cur] != ctxt.peek(cur)
        return ctxt.expecting(@msg)
      end
    end
    ctxt.advance(@vals.length)
    ctxt.retn @vals
  end
end

def downcase c
  case when c >= ?A && c <=?Z then c + (?a - ?A) else c end
end

class StringCaseInsensitiveParser < Parser
  init :str, :msg
  def _parse ctxt
    if @str.length > ctxt.available
      return ctxt.expecting(@msg)
    end
    cur = 0
    for cur in (0...@str.length)
      if downcase(@str[cur]) != downcase(ctxt.peek(cur))
        return ctxt.expecting(@msg)
      end
    end
    result = ctxt.src[ctxt.index, @str.length]
    ctxt.advance(@str.length)
    ctxt.retn result
  end
end

class FragmentParser < Parser
  init :parser
  def _parse ctxt
    ind = ctxt.index
    return false unless @parser._parse ctxt
    ctxt.retn(ctxt.src[ind, ctxt.index-ind])
  end
end

class TokenParser < Parser
  init :symbol, :parser
  def _parse ctxt
    ind = ctxt.index
    return false unless @parser._parse ctxt
    raw = ctxt.result
    raw = ctxt.src[ind, ctxt.index-ind] unless raw.kind_of? String
    ctxt.retn(Token.new(@symbol, raw, ind))
  end
end

class NestedParser < Parser
  init :parser1, :parser2
  def _parse ctxt
    ind = ctxt.index
    return false unless @parser1._parse ctxt
    _run_nested(ind, ctxt, ctxt.result, @parser2)
  end
  private
  def _run_nested(start, ctxt, src, parser)
    ctxt.error = nil
    new_ctxt = nil
    if src.kind_of? String
      new_ctxt = ParseContext.new(src)
      return true if _run_parser parser, ctxt, new_ctxt
      ctxt.index = start + new_ctxt.index
    elsif src.kind_of? Array
      new_ctxt = ParseContext.new(src)
      return true if _run_parser parser, ctxt, new_ctxt
      ctxt.index = start + _get_index(new_ctxt) unless new_ctxt.eof
    else
      new_ctxt = ParseContext.new([src])
      return true if _run_parser parser, ctxt, new_ctxt
      ctxt.index = ind unless new_ctxt.eof
    end
    ctxt.error.index = ctxt.index
    false
  end
  def _get_index ctxt
    cur = ctxt.current
    return cur.index if cur.respond_to? :index
    ctxt.index
  end
  def _run_parser parser, old_ctxt, new_ctxt
    if parser._parse new_ctxt
      old_ctxt.result = new_ctxt.result
      true
    else
      old_ctxt.error = new_ctxt.error
      false
    end
  end
end

class WatchParser < Parser
  init :proc
  def _parse ctxt
    @proc.call(ctxt.result)
    true
  end
end

class WatchnParser < Parser
  init :proc
  def _parse ctxt
    @proc.call(*ctxt.result)
    true
  end
end

class MapCurrentParser < Parser
  init :proc
  def _parse ctxt
    ctxt.result = @proc.call(ctxt.result)
    true
  end
end

class MapnCurrentParser < Parser
  init :proc
  def _parse ctxt
    ctxt.result = @proc.call(*ctxt.result)
    true
  end
end

class Repeat_Parser < Parser
  init :parser, :times
  def _parse ctxt
    for i in (0...@times)
      return false unless @parser._parse ctxt
    end
    return true
  end
end

class RepeatParser < Parser
  init :parser, :times
  def _parse ctxt
    result = []
    for i in (0...@times)
      return false unless @parser._parse ctxt
      result << ctxt.result
    end
    return ctxt.retn(result)
  end
end

class Many_Parser < Parser
  init :parser, :least
  def _parse ctxt
    for i in (0...@least)
      return false unless @parser._parse ctxt
    end
    while(true)
      ind = ctxt.index
      if @parser._parse ctxt
        return true if ind==ctxt.index # infinite loop
        next
      end
      return ind==ctxt.index
    end
  end
end

class ManyParser < Parser
  init :parser, :least
  def _parse ctxt
    result = []
    for i in (0...@least)
      return false unless @parser._parse ctxt
      result << ctxt.result
    end
    while(true)
      ind = ctxt.index
      if @parser._parse ctxt
        result << ctxt.result
        return ctxt.retn(result) if ind==ctxt.index # infinite loop
        next
      end
      if ind==ctxt.index
        return ctxt.retn(result)
      else
        return false
      end
    end
  end
end

class Some_Parser < Parser
  init :parser, :least, :max
  def _parse ctxt
    for i in (0...@least)
      return false unless @parser._parse ctxt
    end
    for i in (@least...@max)
      ind = ctxt.index
      if @parser._parse ctxt
        return true if ind==ctxt.index # infinite loop
        next
      end
      return ind==ctxt.index
    end
    return true
  end
end

class SomeParser < Parser
  init :parser, :least, :max
  def _parse ctxt
    result = []
    for i in (0...@least)
      return false unless @parser._parse ctxt
      result << ctxt.result
    end
    for i in (@least...@max)
      ind = ctxt.index
      if @parser._parse ctxt
        result << ctxt.result
        return ctxt.retn(result) if ind==ctxt.index # infinite loop
        next
      end
      if ind==ctxt.index
        return ctxt.retn(result)
      else
        return false
      end
    end
    return ctxt.retn(result)
  end
end

class OneParser < Parser
  def _parse ctxt
    true
  end
end

class ZeroParser < Parser
  def _parse ctxt
    return ctxt.failure
  end
end

class GetIndexParser < Parser
  def _parse ctxt
    ctxt.retn(ctxt.index)
  end
end
class SetIndexParser < Parser
  init :index
  def _parse ctxt
    ctxt.index = @index
  end
end

Nil = ValueParser.new(nil)

end # module