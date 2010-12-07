#!/usr/local/bin/ruby

require 'rubygems'
require 'minitest/autorun'
require 'ruby_parser'

$: << File.expand_path('~/Work/p4/zss/src/ParseTree/dev/test')

require 'pt_testcase'

class RubyParser
  def process input
    parse input
  end
end

class RubyParserTestCase < ParseTreeTestCase
  def self.previous key
    "Ruby"
  end

  def self.generate_test klass, node, data, input_name, output_name
    return if node.to_s =~ /bmethod|dmethod/
    return if Array === data['Ruby']

    output_name = "ParseTree"

    super
  end
end

class TestRubyParser < RubyParserTestCase
  def setup
    super

    # puts self.name

    @processor = RubyParser.new
  end

  def test_attrasgn_array_lhs
    rb = '[1, 2, 3, 4][from .. to] = ["a", "b", "c"]'
    pt = s(:attrasgn,
           s(:array, s(:lit, 1), s(:lit, 2), s(:lit, 3), s(:lit, 4)),
           :[]=,
           s(:arglist,
             s(:dot2,
               s(:call, nil, :from, s(:arglist)),
               s(:call, nil, :to, s(:arglist))),
             s(:array, s(:str, "a"), s(:str, "b"), s(:str, "c"))))

    result = @processor.parse(rb)

    assert_equal pt, result
  end

  def test_block_append
    head = s(:args)
    tail = s(:zsuper)
    expected = s(:block, s(:args), s(:zsuper))
    assert_equal expected, @processor.block_append(head, tail)
  end

  def test_block_append_begin_begin
    head = s(:begin, s(:args))
    tail = s(:begin, s(:args))
    expected = s(:block, s(:args), s(:begin, s(:args)))
    assert_equal expected, @processor.block_append(head, tail)
  end

  def test_block_append_block
    head = s(:block, s(:args))
    tail = s(:zsuper)
    expected = s(:block, s(:args), s(:zsuper))
    assert_equal expected, @processor.block_append(head, tail)
  end

  def test_block_append_nil_head
    head = nil
    tail = s(:zsuper)
    expected = s(:zsuper)
    assert_equal expected, @processor.block_append(head, tail)
  end

  def test_block_append_nil_tail
    head = s(:args)
    tail = nil
    expected = s(:args)
    assert_equal expected, @processor.block_append(head, tail)
  end

  def test_block_append_tail_block
    head = s(:call, nil, :f1, s(:arglist))
    tail = s(:block, s(:undef, s(:lit, :x)), s(:undef, s(:lit, :y)))
    expected = s(:block,
                 s(:call, nil, :f1, s(:arglist)),
                 s(:block, s(:undef, s(:lit, :x)), s(:undef, s(:lit, :y))))
    assert_equal expected, @processor.block_append(head, tail)
  end

  def test_call_env
    @processor.env[:a] = :lvar
    expected = s(:call, s(:lvar, :a), :happy, s(:arglist))

    assert_equal expected, @processor.parse('a.happy')
  end

  def test_dasgn_icky2
    rb = "a do\n  v = nil\n  begin\n    yield\n  rescue Exception => v\n    break\n  end\nend"
    pt = s(:iter,
           s(:call, nil, :a, s(:arglist)),
           nil,
           s(:block,
             s(:lasgn, :v, s(:nil)),
             s(:rescue,
               s(:yield),
               s(:resbody,
                 s(:array, s(:const, :Exception), s(:lasgn, :v, s(:gvar, :$!))),
                 s(:break)))))

    assert_equal pt, @processor.parse(rb)
  end

  def test_class_comments
    rb = "# blah 1\n# blah 2\n\nclass X\n  # blah 3\n  def blah\n    # blah 4\n  end\nend"
    pt = s(:class, :X, nil,
           s(:scope,
             s(:defn, :blah, s(:args), s(:scope, s(:block, s(:nil))))))

    actual = @processor.parse(rb)
    assert_equal pt, actual

    assert_equal "# blah 1\n# blah 2\n\n", actual.comments
    assert_equal "# blah 3\n", actual.scope.defn.comments
  end

  def test_module_comments
    rb = "# blah 1\n  \n  # blah 2\n\nmodule X\n  # blah 3\n  def blah\n    # blah 4\n  end\nend"
    pt = s(:module, :X,
           s(:scope,
             s(:defn, :blah, s(:args), s(:scope, s(:block, s(:nil))))))

    actual = @processor.parse(rb)
    assert_equal pt, actual
    assert_equal "# blah 1\n\n# blah 2\n\n", actual.comments
    assert_equal "# blah 3\n", actual.scope.defn.comments
  end

  def test_defn_comments
    rb = "# blah 1\n# blah 2\n\ndef blah\nend"
    pt = s(:defn, :blah, s(:args), s(:scope, s(:block, s(:nil))))

    actual = @processor.parse(rb)
    assert_equal pt, actual
    assert_equal "# blah 1\n# blah 2\n\n", actual.comments
  end

  def test_defs_comments
    rb = "# blah 1\n# blah 2\n\ndef self.blah\nend"
    pt = s(:defs, s(:self), :blah, s(:args), s(:scope, s(:block)))

    actual = @processor.parse(rb)
    assert_equal pt, actual
    assert_equal "# blah 1\n# blah 2\n\n", actual.comments
  end

  def test_do_bug # TODO: rename
    rb = "a 1\na.b do |c|\n  # do nothing\nend"
    pt = s(:block,
           s(:call, nil, :a, s(:arglist, s(:lit, 1))),
           s(:iter,
             s(:call, s(:call, nil, :a, s(:arglist)), :b, s(:arglist)),
             s(:lasgn, :c)))

    assert_equal pt, @processor.parse(rb)
  end

  def test_dstr_evstr
    rb = "\"#\{'a'}#\{b}\""
    pt = s(:dstr, "a", s(:evstr, s(:call, nil, :b, s(:arglist))))

    assert_equal pt, @processor.parse(rb)
  end

  def test_dstr_str
    rb = "\"#\{'a'} b\""
    pt = s(:str, "a b")

    assert_equal pt, @processor.parse(rb)
  end

  def test_empty
    rb = ""
    pt = nil

    assert_equal pt, @processor.parse(rb)
  end

  def test_evstr_evstr
    rb = "\"#\{a}#\{b}\""
    pt = s(:dstr, "", s(:evstr, s(:call, nil, :a, s(:arglist))), s(:evstr, s(:call, nil, :b, s(:arglist))))

    assert_equal pt, @processor.parse(rb)
  end

  def test_evstr_str
    rb = "\"#\{a} b\""
    pt = s(:dstr, "", s(:evstr, s(:call, nil, :a, s(:arglist))), s(:str, " b"))

    assert_equal pt, @processor.parse(rb)
  end

  def test_lasgn_env
    rb = 'a = 42'
    pt = s(:lasgn, :a, s(:lit, 42))
    expected_env = { :a => :lvar }

    assert_equal pt, @processor.parse(rb)
    assert_equal expected_env, @processor.env.all
  end

  def test_list_append
    a = s(:lit, 1)
    b = s(:lit, 2)
    c = s(:lit, 3)

    result = @processor.list_append(s(:array, b.dup), c.dup)

    assert_equal s(:array, b, c), result

    result = @processor.list_append(b.dup, c.dup)

    assert_equal s(:array, b, c), result

    result = @processor.list_append(result, a.dup)

    assert_equal s(:array, b, c, a), result

    lhs, rhs = s(:array, s(:lit, :iter)), s(:when, s(:const, :BRANCHING), nil)
    expected = s(:array, s(:lit, :iter), s(:when, s(:const, :BRANCHING), nil))

    assert_equal expected, @processor.list_append(lhs, rhs)
  end

  def test_list_prepend
    a = s(:lit, 1)
    b = s(:lit, 2)
    c = s(:lit, 3)

    result = @processor.list_prepend(b.dup, s(:array, c.dup))

    assert_equal s(:array, b, c), result

    result = @processor.list_prepend(b.dup, c.dup)

    assert_equal s(:array, b, c), result

    result = @processor.list_prepend(a.dup, result)

    assert_equal s(:array, a, b, c), result
  end

  def test_literal_concat_dstr_dstr
    lhs      = s(:dstr, "Failed to download spec ",
                 s(:evstr, s(:call, nil, :spec_name, s(:arglist))),
                 s(:str, " from "),
                 s(:evstr, s(:call, nil, :source_uri, s(:arglist))),
                 s(:str, ":\n"))
    rhs      = s(:dstr, "\t",
                 s(:evstr, s(:call, s(:ivar, :@fetch_error), :message)))
    expected = s(:dstr, "Failed to download spec ",
                 s(:evstr, s(:call, nil, :spec_name, s(:arglist))),
                 s(:str, " from "),
                 s(:evstr, s(:call, nil, :source_uri, s(:arglist))),
                 s(:str, ":\n"),
                 s(:str, "\t"),
                 s(:evstr, s(:call, s(:ivar, :@fetch_error), :message)))

    assert_equal expected, @processor.literal_concat(lhs, rhs)
  end

  def test_literal_concat_dstr_evstr
    lhs, rhs = s(:dstr, "a"), s(:evstr, s(:call, nil, :b, s(:arglist)))
    expected = s(:dstr, "a", s(:evstr, s(:call, nil, :b, s(:arglist))))

    assert_equal expected, @processor.literal_concat(lhs, rhs)
  end

  def test_literal_concat_evstr_evstr
    lhs, rhs = s(:evstr, s(:lit, 1)), s(:evstr, s(:lit, 2))
    expected = s(:dstr, "", s(:evstr, s(:lit, 1)), s(:evstr, s(:lit, 2)))

    assert_equal expected, @processor.literal_concat(lhs, rhs)
  end

  def test_literal_concat_str_evstr
    lhs, rhs = s(:str, ""), s(:evstr, s(:str, "blah"))

    assert_equal s(:str, "blah"), @processor.literal_concat(lhs, rhs)
  end

  def test_logop_12
    lhs = s(:lit, 1)
    rhs = s(:lit, 2)
    exp = s(:and, s(:lit, 1), s(:lit, 2))

    assert_equal exp, @processor.logop(:and, lhs, rhs)
  end

  def test_logop_1234_5
    lhs = s(:and, s(:lit, 1), s(:and, s(:lit, 2), s(:and, s(:lit, 3), s(:lit, 4))))
    rhs = s(:lit, 5)
    exp = s(:and,
            s(:lit, 1),
            s(:and,
              s(:lit, 2),
              s(:and,
                s(:lit, 3),
                s(:and,
                  s(:lit, 4),
                  s(:lit, 5)))))

    assert_equal exp, @processor.logop(:and, lhs, rhs)
  end

  def test_logop_123_4
    lhs = s(:and, s(:lit, 1), s(:and, s(:lit, 2), s(:lit, 3)))
    rhs = s(:lit, 4)
    exp = s(:and,
            s(:lit, 1),
            s(:and,
              s(:lit, 2),
              s(:and,
                s(:lit, 3),
                s(:lit, 4))))

    assert_equal exp, @processor.logop(:and, lhs, rhs)
  end

  def test_logop_12_3
    lhs = s(:and, s(:lit, 1), s(:lit, 2))
    rhs = s(:lit, 3)
    exp = s(:and, s(:lit, 1), s(:and, s(:lit, 2), s(:lit, 3)))

    assert_equal exp, @processor.logop(:and, lhs, rhs)
  end

  def test_logop_nested_mix
    lhs = s(:or, s(:call, nil, :a, s(:arglist)), s(:call, nil, :b, s(:arglist)))
    rhs = s(:and, s(:call, nil, :c, s(:arglist)), s(:call, nil, :d, s(:arglist)))
    exp = s(:or,
            s(:or, s(:call, nil, :a, s(:arglist)), s(:call, nil, :b, s(:arglist))),
            s(:and, s(:call, nil, :c, s(:arglist)), s(:call, nil, :d, s(:arglist))))

    lhs.paren = true
    rhs.paren = true

    assert_equal exp, @processor.logop(:or, lhs, rhs)
  end

  def test_str_evstr
    rb = "\"a #\{b}\""
    pt = s(:dstr, "a ", s(:evstr, s(:call, nil, :b, s(:arglist))))

    assert_equal pt, @processor.parse(rb)
  end

  def test_regexp
    regexps = {
      "/wtf/" => /wtf/,
      "/wtf/n" => /wtf/n,
      "/wtf/m" => /wtf/m,
      "/wtf/nm" => /wtf/nm,
      "/wtf/nmnmnmnm" => /wtf/nm,
    }

    regexps.each do |rb, lit|
      assert_equal s(:lit, lit), @processor.parse(rb)
    end

    # TODO: add more including interpolation etc
  end

  def test_str_pct_Q_nested
    rb = "%Q[before [#\{nest}] after]"
    pt = s(:dstr, "before [", s(:evstr, s(:call, nil, :nest, s(:arglist))), s(:str, "] after"))

    assert_equal pt, @processor.parse(rb)
  end

#   def test_str_pct_nested_nested
#     rb = "%{ { #\{ \"#\{1}\" } } }"
#     pt = s(:dstr, " { ", s(:evstr, s(:lit, 1)), s(:str, " } "))

#     assert_equal pt, @processor.parse(rb)
#   end

  def test_str_str
    rb = "\"a #\{'b'}\""
    pt = s(:str, "a b")

    assert_equal pt, @processor.parse(rb)
  end

  def test_str_str_str
    rb = "\"a #\{'b'} c\""
    pt = s(:str, "a b c")

    assert_equal pt, @processor.parse(rb)
  end

  STARTING_LINE = {
    "case_nested_inner_no_expr"          => 2,
    "case_no_expr"                       => 2,
    "case_splat"                         => 2,
    "dstr_heredoc_expand"                => 2,
    "dstr_heredoc_windoze_sucks"         => 2,
    "dstr_heredoc_yet_again"             => 2,
    "str_heredoc"                        => 2,
    "str_heredoc_call"                   => 2,
    "str_heredoc_empty"                  => 2,
    "str_heredoc_indent"                 => 2,
    "structure_unused_literal_wwtt"      => 3, # yes, 3... odd test
    "undef_block_1"                      => 2,
    "undef_block_2"                      => 2,
    "undef_block_3"                      => 2,
    "undef_block_wtf"                    => 2,
  }

  def after_process_hook klass, node, data, input_name, output_name
    expected = STARTING_LINE[node] || 1
    assert_equal expected, @result.line, "should have proper line number"
  end

  def test_position_info
    rb = "a = 42\np a"
    pt = s(:block,
           s(:lasgn, :a, s(:lit, 42)),
           s(:call, nil, :p, s(:arglist, s(:lvar, :a))))

    result = @processor.parse(rb, "blah.rb")

    assert_equal pt, result

    assert_equal 1, result.line,       "block should have line number"
    assert_equal 1, result.lasgn.line, "lasgn should have line number"
    assert_equal 2, result.call.line,  "call should have line number"

    expected = "blah.rb"

    assert_equal expected, result.file
    assert_equal expected, result.lasgn.file
    assert_equal expected, result.call.file

    assert_same result.file, result.lasgn.file
    assert_same result.file, result.call.file
  end

  def test_position_info2
    rb = "def x(y)\n  p(y)\n  y *= 2\n  return y;\nend" # TODO: remove () & ;
    pt = s(:defn, :x, s(:args, :y),
           s(:scope,
             s(:block,
               s(:call, nil, :p, s(:arglist, s(:lvar, :y))),
               s(:lasgn, :y,
                 s(:call, s(:lvar, :y), :*, s(:arglist, s(:lit, 2)))),
               s(:return, s(:lvar, :y)))))

    result = @processor.parse(rb)

    assert_equal pt, result

    body = result.scope.block

    assert_equal 1, result.line,      "defn should have line number"
    assert_equal 2, body.call.line,   "call should have line number"
    assert_equal 3, body.lasgn.line,  "lasgn should have line number"
    assert_equal 4, body.return.line, "return should have line number"
  end
end
