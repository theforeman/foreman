#!/usr/local/bin/ruby

require 'rubygems'
require 'minitest/autorun'
require 'ruby_lexer'
require 'ruby_parser'

class TestRubyLexer < MiniTest::Unit::TestCase
  alias :deny :refute

  def setup
    p = RubyParser.new
    @lex = p.lexer
    @lex.src = "blah blah"
    @lex.lex_state = :expr_beg
  end

  def test_advance
    assert @lex.advance # blah
    assert @lex.advance # blah
    deny   @lex.advance # nada
  end

  def test_read_escape
    util_escape "\\",   "\\"
    util_escape "\n",   "n"
    util_escape "\t",   "t"
    util_escape "\r",   "r"
    util_escape "\f",   "f"
    util_escape "\13",  "v"
    util_escape "\0",   "0"
    util_escape "\07",  "a"
    util_escape "\007", "a"
    util_escape "\033", "e"
    util_escape "\377", "377"
    util_escape "\377", "xff"
    util_escape "\010", "b"
    util_escape " ",    "s"
    util_escape "q",    "q" # plain vanilla escape
  end

  def test_read_escape_c
    util_escape "\030", "C-x"
    util_escape "\030", "cx"
    util_escape "\230", 'C-\M-x'
    util_escape "\230", 'c\M-x'

    util_escape "\177", "C-?"
    util_escape "\177", "c?"
  end

  def test_read_escape_errors
    util_escape_bad ""

    util_escape_bad "M"
    util_escape_bad "M-"
    util_escape_bad "Mx"

    util_escape_bad "Cx"
    util_escape_bad "C"
    util_escape_bad "C-"

    util_escape_bad "c"
  end

  def test_read_escape_m
    util_escape "\370", "M-x"
    util_escape "\230", 'M-\C-x'
    util_escape "\230", 'M-\cx'
  end

  def test_yylex_ambiguous_uminus
    util_lex_token("m -3",
                   :tIDENTIFIER, "m",
                   :tUMINUS_NUM, "-",
                   :tINTEGER, 3)
    # TODO: verify warning
  end

  def test_yylex_ambiguous_uplus
    util_lex_token("m +3",
                   :tIDENTIFIER, "m",
                   :tINTEGER, 3)
    # TODO: verify warning
  end

  def test_yylex_and
    util_lex_token "&", :tAMPER, "&"
  end

  def test_yylex_and2
    util_lex_token "&&", :tANDOP, "&&"
  end

  def test_yylex_and2_equals
    util_lex_token "&&=", :tOP_ASGN, "&&"
  end

  def test_yylex_and_arg
    @lex.lex_state = :expr_arg

    util_lex_token(" &y",
                   :tAMPER, "&",
                   :tIDENTIFIER, "y")
  end

  def test_yylex_and_equals
    util_lex_token "&=", :tOP_ASGN, "&"
  end

  def test_yylex_and_expr
    @lex.lex_state = :expr_arg

    util_lex_token("x & y",
                   :tIDENTIFIER, "x",
                   :tAMPER2, "&",
                   :tIDENTIFIER, "y")
  end

  def test_yylex_and_meth
    util_lex_fname "&", :tAMPER2
  end

  def test_yylex_assoc
    util_lex_token "=>", :tASSOC, "=>"
  end

  def test_yylex_back_ref
    util_lex_token("[$&, $`, $', $+]",
                   :tLBRACK,   "[",
                   :tBACK_REF, :"&", :tCOMMA, ",",
                   :tBACK_REF, :"`", :tCOMMA, ",",
                   :tBACK_REF, :"'", :tCOMMA, ",",
                   :tBACK_REF, :"+",
                   :tRBRACK,   "]")
  end

  def test_yylex_backslash
    util_lex_token("1 \\\n+ 2",
                   :tINTEGER, 1,
                   :tPLUS, "+",
                   :tINTEGER, 2)
  end

  def test_yylex_backslash_bad
    util_bad_token("1 \\ + 2",
                   :tINTEGER, 1)
  end

  def test_yylex_backtick
    util_lex_token("`ls`",
                   :tXSTRING_BEG, "`",
                   :tSTRING_CONTENT, "ls",
                   :tSTRING_END, "`")
  end

  def test_yylex_backtick_cmdarg
    @lex.lex_state = :expr_dot
    util_lex_token("\n`", :tBACK_REF2, "`") # \n ensures expr_cmd

    assert_equal :expr_cmdarg, @lex.lex_state
  end

  def test_yylex_backtick_dot
    @lex.lex_state = :expr_dot
    util_lex_token("a.`(3)",
                   :tIDENTIFIER, "a",
                   :tDOT, ".",
                   :tBACK_REF2, "`",
                   :tLPAREN2, "(",
                   :tINTEGER, 3,
                   :tRPAREN, ")")
  end

  def test_yylex_backtick_method
    @lex.lex_state = :expr_fname
    util_lex_token("`", :tBACK_REF2, "`")
    assert_equal :expr_end, @lex.lex_state
  end

  def test_yylex_bad_char
    util_bad_token(" \010 ")
  end

  def test_yylex_bang
    util_lex_token "!", :tBANG, "!"
  end

  def test_yylex_bang_equals
    util_lex_token "!=", :tNEQ, "!="
  end

  def test_yylex_bang_tilde
    util_lex_token "!~", :tNMATCH, "!~"
  end

  def test_yylex_carat
    util_lex_token "^", :tCARET, "^"
  end

  def test_yylex_carat_equals
    util_lex_token "^=", :tOP_ASGN, "^"
  end

  def test_yylex_colon2
    util_lex_token("A::B",
                   :tCONSTANT, "A",
                   :tCOLON2,   "::",
                   :tCONSTANT, "B")
  end

  def test_yylex_colon3
    util_lex_token("::Array",
                   :tCOLON3, "::",
                   :tCONSTANT, "Array")
  end

  def test_yylex_comma
    util_lex_token ",", :tCOMMA, ","
  end

  def test_yylex_comment
    util_lex_token("1 # one\n# two\n2",
                   :tINTEGER, 1,
                   :tNL, nil,
                   :tINTEGER, 2)
    assert_equal "# one\n# two\n", @lex.comments
  end

  def test_yylex_comment_begin
    util_lex_token("=begin\nblah\nblah\n=end\n42",
                   :tINTEGER, 42)
    assert_equal "=begin\nblah\nblah\n=end\n", @lex.comments
  end

  def test_yylex_comment_begin_bad
    util_bad_token("=begin\nblah\nblah\n")
    assert_equal "", @lex.comments
  end

  def test_yylex_comment_begin_not_comment
    util_lex_token("beginfoo = 5\np x \\\n=beginfoo",
                   :tIDENTIFIER, "beginfoo",
                   :tEQL,          "=",
                   :tINTEGER,    5,
                   :tNL,         nil,
                   :tIDENTIFIER, "p",
                   :tIDENTIFIER, "x",
                   :tEQL,          "=",
                   :tIDENTIFIER, "beginfoo")
  end

  def test_yylex_comment_begin_space
    util_lex_token("=begin blah\nblah\n=end\n")
    assert_equal "=begin blah\nblah\n=end\n", @lex.comments
  end

  def test_yylex_comment_eos
    util_lex_token("# comment")
  end

  def test_yylex_constant
    util_lex_token("ArgumentError",
                   :tCONSTANT, "ArgumentError")
  end

  def test_yylex_constant_semi
    util_lex_token("ArgumentError;",
                   :tCONSTANT, "ArgumentError",
                   :tSEMI, ";")
  end

  def test_yylex_cvar
    util_lex_token "@@blah", :tCVAR, "@@blah"
  end

  def test_yylex_cvar_bad
    assert_raises SyntaxError do
      util_lex_token "@@1"
    end
  end

  def test_yylex_def_bad_name
    @lex.lex_state = :expr_fname
    util_bad_token("def [ ", :kDEF, "def")
  end

  def test_yylex_div
    util_lex_token("a / 2",
                   :tIDENTIFIER, "a",
                   :tDIVIDE, "/",
                   :tINTEGER, 2)
  end

  def test_yylex_div_equals
    util_lex_token("a /= 2",
                   :tIDENTIFIER, "a",
                   :tOP_ASGN, "/",
                   :tINTEGER, 2)
  end

  def test_yylex_do
    util_lex_token("x do 42 end",
                   :tIDENTIFIER, "x",
                   :kDO, "do",
                   :tINTEGER, 42,
                   :kEND, "end")
  end

  def test_yylex_do_block
    @lex.lex_state = :expr_endarg
    @lex.cmdarg.push true

    util_lex_token("x.y do 42 end",
                   :tIDENTIFIER, "x",
                   :tDOT, ".",
                   :tIDENTIFIER, "y",
                   :kDO_BLOCK, "do",
                   :tINTEGER, 42,
                   :kEND, "end")
  end

  def test_yylex_do_block2
    @lex.lex_state = :expr_endarg

    util_lex_token("do 42 end",
                   :kDO_BLOCK, "do",
                   :tINTEGER, 42,
                   :kEND, "end")
  end

  def test_yylex_do_cond
    @lex.cond.push true

    util_lex_token("x do 42 end",
                   :tIDENTIFIER, "x",
                   :kDO_COND, "do",
                   :tINTEGER, 42,
                   :kEND, "end")
  end

  def test_yylex_dollar
    util_lex_token("$", "$", "$") # FIX: wtf is this?!?
  end

  def test_yylex_dot # HINT message sends
    util_lex_token ".", :tDOT, "."
  end

  def test_yylex_dot2
    util_lex_token "..", :tDOT2, ".."
  end

  def test_yylex_dot3
    util_lex_token "...", :tDOT3, "..."
  end

  def test_yylex_equals
    util_lex_token "=", :tEQL, "=" # FIX: this sucks
  end

  def test_yylex_equals2
    util_lex_token "==", :tEQ, "=="
  end

  def test_yylex_equals3
    util_lex_token "===", :tEQQ, "==="
  end

  def test_yylex_equals_tilde
    util_lex_token "=~", :tMATCH, "=~"
  end

  def test_yylex_float
    util_lex_token "1.0", :tFLOAT, 1.0
  end

  def test_yylex_float_bad_no_underscores
    util_bad_token "1__0.0"
  end

  def test_yylex_float_bad_no_zero_leading
    util_bad_token ".0"
  end

  def test_yylex_float_bad_trailing_underscore
    util_bad_token "123_.0"
  end

  def test_yylex_float_call
    util_lex_token("1.0.to_s",
                   :tFLOAT, 1.0,
                   :tDOT, ".",
                   :tIDENTIFIER, "to_s")
  end

  def test_yylex_float_dot_E
    util_lex_token "1.0E10", :tFLOAT, 1.0e10
  end

  def test_yylex_float_dot_E_neg
    util_lex_token("-1.0E10",
                   :tUMINUS_NUM, "-",
                   :tFLOAT, 1.0e10)
  end

  def test_yylex_float_dot_e
    util_lex_token "1.0e10", :tFLOAT, 1.0e10
  end

  def test_yylex_float_dot_e_neg
    util_lex_token("-1.0e10",
                   :tUMINUS_NUM, "-",
                   :tFLOAT, 1.0e10)
  end

  def test_yylex_float_e
    util_lex_token "1e10", :tFLOAT, 1e10
  end

  def test_yylex_float_e_bad_double_e
    util_bad_token "1e2e3"
  end

  def test_yylex_float_e_bad_trailing_underscore
    util_bad_token "123_e10"
  end

  def test_yylex_float_e_minus
    util_lex_token "1e-10", :tFLOAT, 1e-10
  end

  def test_yylex_float_e_neg
    util_lex_token("-1e10",
                   :tUMINUS_NUM, "-",
                   :tFLOAT, 1e10)
  end

  def test_yylex_float_e_neg_minus
    util_lex_token("-1e-10",
                   :tUMINUS_NUM, "-",
                   :tFLOAT, 1e-10)
  end

  def test_yylex_float_e_neg_plus
    util_lex_token("-1e+10",
                   :tUMINUS_NUM, "-",
                   :tFLOAT, 1e10)
  end

  def test_yylex_float_e_plus
    util_lex_token "1e+10", :tFLOAT, 1e10
  end

  def test_yylex_float_e_zero
    util_lex_token "0e0", :tFLOAT, 0e0
  end

  def test_yylex_float_neg
    util_lex_token("-1.0",
                   :tUMINUS_NUM, "-",
                   :tFLOAT, 1.0)
  end

  def test_yylex_ge
    util_lex_token("a >= 2",
                   :tIDENTIFIER, "a",
                   :tGEQ, ">=",
                   :tINTEGER, 2)
  end

  def test_yylex_global
    util_lex_token("$blah", :tGVAR, "$blah")
  end

  def test_yylex_global_backref
    @lex.lex_state = :expr_fname
    util_lex_token("$`", :tGVAR, "$`")
  end

  def test_yylex_global_dash_nothing
    util_lex_token("$- ", :tGVAR, "$-")
  end

  def test_yylex_global_dash_something
    util_lex_token("$-x", :tGVAR, "$-x")
  end

  def test_yylex_global_number
    @lex.lex_state = :expr_fname
    util_lex_token("$1", :tGVAR, "$1")
  end

  def test_yylex_global_number_big
    @lex.lex_state = :expr_fname
    util_lex_token("$1234", :tGVAR, "$1234")
  end

  def test_yylex_global_other
    util_lex_token("[$~, $*, $$, $?, $!, $@, $/, $\\, $;, $,, $., $=, $:, $<, $>, $\"]",
                   :tLBRACK, "[",
                   :tGVAR,   "$~",  :tCOMMA, ",",
                   :tGVAR,   "$*",  :tCOMMA, ",",
                   :tGVAR,   "$$",  :tCOMMA, ",",
                   :tGVAR,   "$\?",  :tCOMMA, ",",
                   :tGVAR,   "$!",  :tCOMMA, ",",
                   :tGVAR,   "$@",  :tCOMMA, ",",
                   :tGVAR,   "$/",  :tCOMMA, ",",
                   :tGVAR,   "$\\", :tCOMMA, ",",
                   :tGVAR,   "$;",  :tCOMMA, ",",
                   :tGVAR,   "$,",  :tCOMMA, ",",
                   :tGVAR,   "$.",  :tCOMMA, ",",
                   :tGVAR,   "$=",  :tCOMMA, ",",
                   :tGVAR,   "$:",  :tCOMMA, ",",
                   :tGVAR,   "$<",  :tCOMMA, ",",
                   :tGVAR,   "$>",  :tCOMMA, ",",
                   :tGVAR,   "$\"",
                   :tRBRACK, "]")
  end

  def test_yylex_global_underscore
    util_lex_token("$_",
                   :tGVAR,     "$_")
  end

  def test_yylex_global_wierd
    util_lex_token("$__blah",
                   :tGVAR,     "$__blah")
  end

  def test_yylex_global_zero
    util_lex_token("$0", :tGVAR, "$0")
  end

  def test_yylex_gt
    util_lex_token("a > 2",
                   :tIDENTIFIER, "a",
                   :tGT, ">",
                   :tINTEGER, 2)
  end

  def test_yylex_heredoc_backtick
    util_lex_token("a = <<`EOF`\n  blah blah\nEOF\n",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tXSTRING_BEG,    "`",
                   :tSTRING_CONTENT, "  blah blah\n",
                   :tSTRING_END,     "EOF",
                   :tNL,             nil)
  end

  def test_yylex_heredoc_double
    util_lex_token("a = <<\"EOF\"\n  blah blah\nEOF\n",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"",
                   :tSTRING_CONTENT, "  blah blah\n",
                   :tSTRING_END,     "EOF",
                   :tNL,             nil)
  end

  def test_yylex_heredoc_double_dash
    util_lex_token("a = <<-\"EOF\"\n  blah blah\n  EOF\n",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"",
                   :tSTRING_CONTENT, "  blah blah\n",
                   :tSTRING_END,     "EOF",
                   :tNL,             nil)
  end

  def test_yylex_heredoc_double_eos
    util_bad_token("a = <<\"EOF\"\nblah",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"")
  end

  def test_yylex_heredoc_double_eos_nl
    util_bad_token("a = <<\"EOF\"\nblah\n",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"")
  end

  def test_yylex_heredoc_double_interp
    util_lex_token("a = <<\"EOF\"\n#x a \#@a b \#$b c \#{3} \nEOF\n",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"",
                   :tSTRING_CONTENT, "#x a ",
                   :tSTRING_DVAR,    "\#@",
                   :tSTRING_CONTENT, "@a b ", # HUH?
                   :tSTRING_DVAR,    "\#$",
                   :tSTRING_CONTENT, "$b c ", # HUH?
                   :tSTRING_DBEG,    "\#{",
                   :tSTRING_CONTENT, "3} \n", # HUH?
                   :tSTRING_END,     "EOF",
                   :tNL,             nil)
  end

  def test_yylex_heredoc_none
    util_lex_token("a = <<EOF\nblah\nblah\nEOF",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"",
                   :tSTRING_CONTENT, "blah\nblah\n",
                   :tSTRING_CONTENT, "",
                   :tSTRING_END,     "EOF",
                   :tNL,             nil)
  end

  def test_yylex_heredoc_none_bad_eos
    util_bad_token("a = <<EOF",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"")
  end

  def test_yylex_heredoc_none_dash
    util_lex_token("a = <<-EOF\nblah\nblah\n  EOF",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"",
                   :tSTRING_CONTENT, "blah\nblah\n",
                   :tSTRING_CONTENT, "",
                   :tSTRING_END,     "EOF",
                   :tNL,             nil)
  end

  def test_yylex_heredoc_single
    util_lex_token("a = <<'EOF'\n  blah blah\nEOF\n",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"",
                   :tSTRING_CONTENT, "  blah blah\n",
                   :tSTRING_END,     "EOF",
                   :tNL,             nil)
  end

  def test_yylex_heredoc_single_bad_eos_body
    util_bad_token("a = <<'EOF'\nblah",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"")
  end

  def test_yylex_heredoc_single_bad_eos_empty
    util_bad_token("a = <<''\n",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"")
  end

  def test_yylex_heredoc_single_bad_eos_term
    util_bad_token("a = <<'EOF",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"")
  end

  def test_yylex_heredoc_single_bad_eos_term_nl
    util_bad_token("a = <<'EOF\ns = 'blah blah'",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"")
  end

  def test_yylex_heredoc_single_dash
    util_lex_token("a = <<-'EOF'\n  blah blah\n  EOF\n",
                   :tIDENTIFIER,     "a",
                   :tEQL,              "=",
                   :tSTRING_BEG,     "\"",
                   :tSTRING_CONTENT, "  blah blah\n",
                   :tSTRING_END,     "EOF",
                   :tNL,             nil)
  end

  def test_yylex_identifier
    util_lex_token("identifier", :tIDENTIFIER, "identifier")
  end

  def test_yylex_identifier_bang
    util_lex_token("identifier!", :tFID, "identifier!")
  end

  def test_yylex_identifier_cmp
    util_lex_fname "<=>", :tCMP
  end

  def test_yylex_identifier_def
    util_lex_fname "identifier", :tIDENTIFIER, :expr_end
  end

  def test_yylex_identifier_eh
    util_lex_token("identifier?", :tFID, "identifier?")
  end

  def test_yylex_identifier_equals_arrow
    @lex.lex_state = :expr_fname
    util_lex_token(":blah==>",
                   :tSYMBOL, "blah=",
                   :tASSOC, "=>")
  end

  def test_yylex_identifier_equals_caret
    util_lex_fname "^", :tCARET
  end

  def test_yylex_identifier_equals_def
    util_lex_fname "identifier=", :tIDENTIFIER, :expr_end
  end

  def test_yylex_identifier_equals_def2
    util_lex_fname "==", :tEQ
  end

  def test_yylex_identifier_equals_expr
    @lex.lex_state = :expr_dot
    util_lex_token("y = arg",
                   :tIDENTIFIER, "y",
                   :tEQL, "=",
                   :tIDENTIFIER, "arg")

    assert_equal :expr_arg, @lex.lex_state
  end

  def test_yylex_identifier_equals_or
    util_lex_fname "|", :tPIPE
  end

  def test_yylex_identifier_equals_slash
    util_lex_fname "/", :tDIVIDE
  end

  def test_yylex_identifier_equals_tilde
    @lex.lex_state = :expr_fname # can only set via parser's defs
    util_lex_token("identifier=~",
                   :tIDENTIFIER, "identifier",
                   :tMATCH, "=~")
  end

  def test_yylex_identifier_gt
    util_lex_fname ">", :tGT
  end

  def test_yylex_identifier_le
    util_lex_fname "<=", :tLEQ
  end

  def test_yylex_identifier_lt
    util_lex_fname "<", :tLT
  end

  def test_yylex_identifier_tilde
    util_lex_fname "~", :tTILDE
  end

  def test_yylex_index
    util_lex_fname "[]", :tAREF
  end

  def test_yylex_index_equals
    util_lex_fname "[]=", :tASET
  end

  def test_yylex_integer
    util_lex_token "42", :tINTEGER, 42
  end

  def test_yylex_integer_bin
    util_lex_token "0b101010", :tINTEGER, 42
  end

  def test_yylex_integer_bin_bad_none
    util_bad_token "0b "
  end

  def test_yylex_integer_bin_bad_underscores
    util_bad_token "0b10__01"
  end

  def test_yylex_integer_dec
    util_lex_token "42", :tINTEGER, 42
  end

  def test_yylex_integer_dec_bad_underscores
    util_bad_token "42__24"
  end

  def test_yylex_integer_dec_d
    util_lex_token "0d42", :tINTEGER, 42
  end

  def test_yylex_integer_dec_d_bad_none
    util_bad_token "0d"
  end

  def test_yylex_integer_dec_d_bad_underscores
    util_bad_token "0d42__24"
  end

  def test_yylex_integer_eh_a
    util_lex_token '?a', :tINTEGER, 97
  end

  def test_yylex_integer_eh_escape_M_escape_C
    util_lex_token '?\M-\C-a', :tINTEGER, 129
  end

  def test_yylex_integer_hex
    util_lex_token "0x2a", :tINTEGER, 42
  end

  def test_yylex_integer_hex_bad_none
    util_bad_token "0x "
  end

  def test_yylex_integer_hex_bad_underscores
    util_bad_token "0xab__cd"
  end

  def test_yylex_integer_oct
    util_lex_token "052", :tINTEGER, 42
  end

  def test_yylex_integer_oct_bad_range
    util_bad_token "08"
  end

  def test_yylex_integer_oct_bad_underscores
    util_bad_token "01__23"
  end

  def test_yylex_integer_oct_O
    util_lex_token "0O52", :tINTEGER, 42
  end

  def test_yylex_integer_oct_O_bad_range
    util_bad_token "0O8"
  end

  def test_yylex_integer_oct_O_bad_underscores
    util_bad_token "0O1__23"
  end

  def test_yylex_integer_oct_O_not_bad_none
    util_lex_token "0O ", :tINTEGER, 0
  end

  def test_yylex_integer_oct_o
    util_lex_token "0o52", :tINTEGER, 42
  end

  def test_yylex_integer_oct_o_bad_range
    util_bad_token "0o8"
  end

  def test_yylex_integer_oct_o_bad_underscores
    util_bad_token "0o1__23"
  end

  def test_yylex_integer_oct_o_not_bad_none
    util_lex_token "0o ", :tINTEGER, 0
  end

  def test_yylex_integer_trailing
    util_lex_token("1.to_s",
                   :tINTEGER, 1,
                   :tDOT, '.',
                   :tIDENTIFIER, 'to_s')
  end

  def test_yylex_integer_underscore
    util_lex_token "4_2", :tINTEGER, 42
  end

  def test_yylex_integer_underscore_bad
    util_bad_token "4__2"
  end

  def test_yylex_integer_zero
    util_lex_token "0", :tINTEGER, 0
  end

  def test_yylex_ivar
    util_lex_token "@blah", :tIVAR, "@blah"
  end

  def test_yylex_ivar_bad
    util_bad_token "@1"
  end

  def test_yylex_keyword_expr
    @lex.lex_state = :expr_endarg

    util_lex_token("if", :kIF_MOD, "if")

    assert_equal :expr_beg, @lex.lex_state
  end

  def test_yylex_lt
    util_lex_token "<", :tLT, "<"
  end

  def test_yylex_lt2
    util_lex_token("a <\< b",
                   :tIDENTIFIER, "a",
                   :tLSHFT, "<\<",
                   :tIDENTIFIER, "b")

  end

  def test_yylex_lt2_equals
    util_lex_token("a <\<= b",
                   :tIDENTIFIER, "a",
                   :tOP_ASGN, "<\<",
                   :tIDENTIFIER, "b")
  end

  def test_yylex_lt_equals
    util_lex_token "<=", :tLEQ, "<="
  end

  def test_yylex_minus
    util_lex_token("1 - 2",
                   :tINTEGER, 1,
                   :tMINUS, "-",
                   :tINTEGER, 2)
  end

  def test_yylex_minus_equals
    util_lex_token "-=", :tOP_ASGN, "-"
  end

  def test_yylex_minus_method
    @lex.lex_state = :expr_fname
    util_lex_token "-", :tMINUS, "-"
  end

  def test_yylex_minus_unary_method
    @lex.lex_state = :expr_fname
    util_lex_token "-@", :tUMINUS, "-@"
  end

  def test_yylex_minus_unary_number
    util_lex_token("-42",
                   :tUMINUS_NUM, "-",
                   :tINTEGER, 42)
  end

  def test_yylex_nth_ref
    util_lex_token('[$1, $2, $3, $4, $5, $6, $7, $8, $9]',
                   :tLBRACK,  "[",
                   :tNTH_REF, 1, :tCOMMA, ",",
                   :tNTH_REF, 2, :tCOMMA, ",",
                   :tNTH_REF, 3, :tCOMMA, ",",
                   :tNTH_REF, 4, :tCOMMA, ",",
                   :tNTH_REF, 5, :tCOMMA, ",",
                   :tNTH_REF, 6, :tCOMMA, ",",
                   :tNTH_REF, 7, :tCOMMA, ",",
                   :tNTH_REF, 8, :tCOMMA, ",",
                   :tNTH_REF, 9,
                   :tRBRACK,  "]")
  end

  def test_yylex_open_bracket
    util_lex_token("(", :tLPAREN, "(")
  end

  def test_yylex_open_bracket_cmdarg
    @lex.lex_state = :expr_cmdarg
    util_lex_token(" (", :tLPAREN_ARG, "(")
  end

  def test_yylex_open_bracket_exprarg
    @lex.lex_state = :expr_arg
    util_lex_token(" (", :tLPAREN2, "(")
  end

  def test_yylex_open_curly_bracket
    util_lex_token("{",
                   :tLBRACE, "{")
  end

  def test_yylex_open_curly_bracket_arg
    @lex.lex_state = :expr_arg
    util_lex_token("m { 3 }",
                   :tIDENTIFIER, "m",
                   :tLCURLY, "{",
                   :tINTEGER, 3,
                   :tRCURLY, "}")
  end

  def test_yylex_open_curly_bracket_block
    @lex.lex_state = :expr_endarg # seen m(3)
    util_lex_token("{ 4 }",
                   :tLBRACE_ARG, "{",
                   :tINTEGER, 4,
                   :tRCURLY, "}")
  end

  def test_yylex_open_square_bracket_arg
    @lex.lex_state = :expr_arg
    util_lex_token("m [ 3 ]",
                   :tIDENTIFIER, "m",
                   :tLBRACK, "[",
                   :tINTEGER, 3,
                   :tRBRACK, "]")
  end

  def test_yylex_open_square_bracket_ary
    util_lex_token("[1, 2, 3]",
                   :tLBRACK, "[",
                   :tINTEGER, 1,
                   :tCOMMA, ",",
                   :tINTEGER, 2,
                   :tCOMMA, ",",
                   :tINTEGER, 3,
                   :tRBRACK, "]")
  end

  def test_yylex_open_square_bracket_meth
    util_lex_token("m[3]",
                   :tIDENTIFIER, "m",
                   "[", "[",
                   :tINTEGER, 3,
                   :tRBRACK, "]")
  end

  def test_yylex_or
    util_lex_token "|", :tPIPE, "|"
  end

  def test_yylex_or2
    util_lex_token "||", :tOROP, "||"
  end

  def test_yylex_or2_equals
    util_lex_token "||=", :tOP_ASGN, "||"
  end

  def test_yylex_or_equals
    util_lex_token "|=", :tOP_ASGN, "|"
  end

  def test_yylex_percent
    util_lex_token("a % 2",
                   :tIDENTIFIER, "a",
                   :tPERCENT, "%",
                   :tINTEGER, 2)
  end

  def test_yylex_percent_equals
    util_lex_token("a %= 2",
                   :tIDENTIFIER, "a",
                   :tOP_ASGN, "%",
                   :tINTEGER, 2)
  end

  def test_yylex_plus
    util_lex_token("1 + 1", # TODO lex_state?
                   :tINTEGER, 1,
                   :tPLUS, "+",
                   :tINTEGER, 1)
  end

  def test_yylex_plus_equals
    util_lex_token "+=", :tOP_ASGN, "+"
  end

  def test_yylex_plus_method
    @lex.lex_state = :expr_fname
    util_lex_token "+", :tPLUS, "+"
  end

  def test_yylex_plus_unary_method
    @lex.lex_state = :expr_fname
    util_lex_token "+@", :tUPLUS, "+@"
  end

  def test_yylex_plus_unary_number
    util_lex_token("+42",
                   :tINTEGER, 42)
  end

  def test_yylex_question
    util_lex_token "?*", :tINTEGER, 42
  end

  def test_yylex_question_bad_eos
    util_bad_token "?"
  end

  def test_yylex_question_ws
    util_lex_token "? ",  :tEH, "?"
    util_lex_token "?\n", :tEH, "?"
    util_lex_token "?\t", :tEH, "?"
    util_lex_token "?\v", :tEH, "?"
    util_lex_token "?\r", :tEH, "?"
    util_lex_token "?\f", :tEH, "?"
  end

  def test_yylex_question_ws_backslashed
    @lex.lex_state = :expr_beg
    util_lex_token "?\\ ", :tINTEGER, 32
    @lex.lex_state = :expr_beg
    util_lex_token "?\\n", :tINTEGER, 10
    @lex.lex_state = :expr_beg
    util_lex_token "?\\t", :tINTEGER, 9
    @lex.lex_state = :expr_beg
    util_lex_token "?\\v", :tINTEGER, 11
    @lex.lex_state = :expr_beg
    util_lex_token "?\\r", :tINTEGER, 13
    @lex.lex_state = :expr_beg
    util_lex_token "?\\f", :tINTEGER, 12
  end

  def test_yylex_rbracket
    util_lex_token "]", :tRBRACK, "]"
  end

  def test_yylex_rcurly
    util_lex_token "}", :tRCURLY, "}"
  end

  def test_yylex_regexp
    util_lex_token("/regexp/",
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regexp",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_ambiguous
    util_lex_token("method /regexp/",
                   :tIDENTIFIER,     "method",
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regexp",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_bad
    util_bad_token("/.*/xyz",
                   :tREGEXP_BEG, "/",
                   :tSTRING_CONTENT, ".*")
  end

  def test_yylex_regexp_escape_C
    util_lex_token('/regex\\C-x/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\C-x",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_C_M
    util_lex_token('/regex\\C-\\M-x/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\C-\\M-x",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_C_M_craaaazy
    util_lex_token("/regex\\C-\\\n\\M-x/",
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\C-\\M-x",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_C_bad_dash
    util_bad_token '/regex\\Cx/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_C_bad_dash_eos
    util_bad_token '/regex\\C-/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_C_bad_dash_eos2
    util_bad_token '/regex\\C-', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_C_bad_eos
    util_bad_token '/regex\\C/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_C_bad_eos2
    util_bad_token '/regex\\c', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_M
    util_lex_token('/regex\\M-x/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\M-x",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_M_C
    util_lex_token('/regex\\M-\\C-x/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\M-\\C-x",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_M_bad_dash
    util_bad_token '/regex\\Mx/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_M_bad_dash_eos
    util_bad_token '/regex\\M-/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_M_bad_dash_eos2
    util_bad_token '/regex\\M-', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_M_bad_eos
    util_bad_token '/regex\\M/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_backslash_slash
    util_lex_token('/\\//',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, '\\/',
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_backslash_terminator
    util_lex_token('%r%blah\\%blah%',
                   :tREGEXP_BEG,     "%r\000", # FIX ?!?
                   :tSTRING_CONTENT, "blah\\%blah",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_backslash_terminator_meta1
    util_lex_token('%r{blah\\}blah}',
                   :tREGEXP_BEG,     "%r{", # FIX ?!?
                   :tSTRING_CONTENT, "blah\\}blah",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_backslash_terminator_meta2
    util_lex_token('%r/blah\\/blah/',
                   :tREGEXP_BEG,     "%r\000", # FIX ?!?
                   :tSTRING_CONTENT, "blah\\/blah",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_backslash_terminator_meta3
    util_lex_token('%r/blah\\%blah/',
                   :tREGEXP_BEG,     "%r\000", # FIX ?!?
                   :tSTRING_CONTENT, "blah\\%blah",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_bad_eos
    util_bad_token '/regex\\', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_bs
    util_lex_token('/regex\\\\regex/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\\\regex",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_c
    util_lex_token('/regex\\cxxx/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\cxxx",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_c_backslash
    util_lex_token('/regex\\c\\n/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\c\\n",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_chars
    util_lex_token('/re\\tge\\nxp/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "re\\tge\\nxp",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_double_backslash
    regexp = '/[\\/\\\\]$/'
    util_lex_token(regexp,
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, regexp[1..-2],
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_hex
    util_lex_token('/regex\\x61xp/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\x61xp",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_hex_bad
    util_bad_token '/regex\\xzxp/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_hex_one
    util_lex_token('/^[\\xd\\xa]{2}/on',
                   :tREGEXP_BEG,     '/',
                   :tSTRING_CONTENT, '^[\\xd\\xa]{2}',
                   :tREGEXP_END,     'on')
  end

  def test_yylex_regexp_escape_oct1
    util_lex_token('/regex\\0xp/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\0xp",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_oct2
    util_lex_token('/regex\\07xp/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\07xp",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_oct3
    util_lex_token('/regex\\10142/',
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regex\\10142",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_escape_return
    util_lex_token("/regex\\\nregex/",
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, "regexregex",
                   :tREGEXP_END,     "")
  end

  def test_yylex_regexp_nm
    util_lex_token("/.*/nm",
                   :tREGEXP_BEG,     "/",
                   :tSTRING_CONTENT, ".*",
                   :tREGEXP_END,     "nm")
  end

  def test_yylex_rparen
    util_lex_token ")", :tRPAREN, ")"
  end

  def test_yylex_rshft
    util_lex_token("a >> 2",
                   :tIDENTIFIER, "a",
                   :tRSHFT, ">>",
                   :tINTEGER, 2)
  end

  def test_yylex_rshft_equals
    util_lex_token("a >>= 2",
                   :tIDENTIFIER, "a",
                   :tOP_ASGN, ">>",
                   :tINTEGER, 2)
  end

  def test_yylex_star
    util_lex_token("a * ",
                   :tIDENTIFIER, "a",
                   :tSTAR2, "*")

    assert_equal :expr_beg, @lex.lex_state
  end

  def test_yylex_star2
    util_lex_token("a ** ",
                   :tIDENTIFIER, "a",
                   :tPOW, "**")

    assert_equal :expr_beg, @lex.lex_state
  end

  def test_yylex_star2_equals
    util_lex_token("a **= ",
                   :tIDENTIFIER, "a",
                   :tOP_ASGN, "**")

    assert_equal :expr_beg, @lex.lex_state
  end

  def test_yylex_star_arg
    @lex.lex_state = :expr_arg

    util_lex_token(" *a",
                   :tSTAR, "*",
                   :tIDENTIFIER, "a")

    assert_equal :expr_arg, @lex.lex_state
  end

  def test_yylex_star_arg_beg
    @lex.lex_state = :expr_beg

    util_lex_token("*a",
                   :tSTAR, "*",
                   :tIDENTIFIER, "a")

    assert_equal :expr_arg, @lex.lex_state
  end

  def test_yylex_star_arg_beg_fname
    @lex.lex_state = :expr_fname

    util_lex_token("*a",
                   :tSTAR2, "*",
                   :tIDENTIFIER, "a")

    assert_equal :expr_arg, @lex.lex_state
  end

  def test_yylex_star_equals
    util_lex_token("a *= ",
                   :tIDENTIFIER, "a",
                   :tOP_ASGN, "*")

    assert_equal :expr_beg, @lex.lex_state
  end

  def test_yylex_string_bad_eos
    util_bad_token('%',
                   :tSTRING_BEG,     '%')
  end

  def test_yylex_string_bad_eos_quote
    util_bad_token('%{nest',
                   :tSTRING_BEG,     '%}')
  end

  def test_yylex_string_double
    util_lex_token('"string"',
                   :tSTRING, "string")
  end

  def test_yylex_string_double_escape_C
    util_lex_token('"\\C-a"',
                   :tSTRING, "\001")
  end

  def test_yylex_string_double_escape_C_backslash
    util_lex_token('"\\C-\\\\"',
                   :tSTRING_BEG, "\"",
                   :tSTRING_CONTENT, "\034",
                   :tSTRING_END, "\"")
  end

  def test_yylex_string_double_escape_C_escape
    util_lex_token('"\\C-\\M-a"',
                   :tSTRING_BEG, "\"",
                   :tSTRING_CONTENT, "\201",
                   :tSTRING_END, "\"")
  end

  def test_yylex_string_double_escape_C_question
    util_lex_token('"\\C-?"',
                   :tSTRING, "\177")
  end

  def test_yylex_string_double_escape_M
    util_lex_token('"\\M-a"',
                   :tSTRING, "\341")
  end

  def test_yylex_string_double_escape_M_backslash
    util_lex_token('"\\M-\\\\"',
                   :tSTRING_BEG, "\"",
                   :tSTRING_CONTENT, "\334",
                   :tSTRING_END, "\"")
  end

  def test_yylex_string_double_escape_M_escape
    util_lex_token('"\\M-\\C-a"',
                   :tSTRING_BEG, "\"",
                   :tSTRING_CONTENT, "\201",
                   :tSTRING_END, "\"")
  end

  def test_yylex_string_double_escape_bs1
    util_lex_token('"a\\a\\a"',
                   :tSTRING, "a\a\a")
  end

  def test_yylex_string_double_escape_bs2
    util_lex_token('"a\\\\a"',
                   :tSTRING, "a\\a")
  end

  def test_yylex_string_double_escape_c
    util_lex_token('"\\ca"',
                   :tSTRING, "\001")
  end

  def test_yylex_string_double_escape_c_backslash
    util_lex_token('"\\c\\"',
                   :tSTRING_BEG, "\"",
                   :tSTRING_CONTENT, "\034",
                   :tSTRING_END, "\"")
  end

  def test_yylex_string_double_escape_c_escape
    util_lex_token('"\\c\\M-a"',
                   :tSTRING_BEG, "\"",
                   :tSTRING_CONTENT, "\201",
                   :tSTRING_END, "\"")
  end

  def test_yylex_string_double_escape_c_question
    util_lex_token('"\\c?"',
                   :tSTRING, "\177")
  end

  def test_yylex_string_double_escape_chars
    util_lex_token('"s\\tri\\ng"',
                   :tSTRING, "s\tri\ng")
  end

  def test_yylex_string_double_escape_hex
    util_lex_token('"n = \\x61\\x62\\x63"',
                   :tSTRING, "n = abc")
  end

  def test_yylex_string_double_escape_octal
    util_lex_token('"n = \\101\\102\\103"',
                   :tSTRING, "n = ABC")
  end

  def test_yylex_string_double_interp
    util_lex_token("\"blah #x a \#@a b \#$b c \#{3} # \"",
                   :tSTRING_BEG,     "\"",
                   :tSTRING_CONTENT, "blah #x a ",
                   :tSTRING_DVAR,    nil,
                   :tSTRING_CONTENT, "@a b ",
                   :tSTRING_DVAR,    nil,
                   :tSTRING_CONTENT, "$b c ",
                   :tSTRING_DBEG,    nil,
                   :tSTRING_CONTENT, "3} # ",
                   :tSTRING_END,     "\"")
  end

  def test_yylex_string_double_nested_curlies
    util_lex_token('%{nest{one{two}one}nest}',
                   :tSTRING_BEG,     '%}',
                   :tSTRING_CONTENT, "nest{one{two}one}nest",
                   :tSTRING_END,     '}')
  end

  def test_yylex_string_double_no_interp
    util_lex_token("\"# blah\"",                                # pound first
                   :tSTRING, "# blah")

    util_lex_token("\"blah # blah\"",                           # pound not first
                   :tSTRING, "blah # blah")
  end

  def test_yylex_string_escape_x_single
    util_lex_token('"\\x0"',
                   :tSTRING, "\000")
  end

  def test_yylex_string_pct_Q
    util_lex_token("%Q[s1 s2]",
                   :tSTRING_BEG,     "%Q[",
                   :tSTRING_CONTENT, "s1 s2",
                   :tSTRING_END,     "]")
  end

  def test_yylex_string_pct_W
    util_lex_token("%W[s1 s2\ns3]", # TODO: add interpolation to these
                   :tWORDS_BEG,      "%W[",
                   :tSTRING_CONTENT, "s1",
                   :tSPACE,              nil,
                   :tSTRING_CONTENT, "s2",
                   :tSPACE,              nil,
                   :tSTRING_CONTENT, "s3",
                   :tSPACE,              nil,
                   :tSTRING_END,     nil)
  end

  def test_yylex_string_pct_W_bs_nl
    util_lex_token("%W[s1 \\\ns2]", # TODO: add interpolation to these
                   :tWORDS_BEG,      "%W[",
                   :tSTRING_CONTENT, "s1",
                   :tSPACE,              nil,
                   :tSTRING_CONTENT, "\ns2",
                   :tSPACE,              nil,
                   :tSTRING_END,     nil)
  end

  def test_yylex_string_pct_angle
    util_lex_token("%<blah>",
                   :tSTRING_BEG, "%>",
                   :tSTRING_CONTENT, "blah",
                   :tSTRING_END, ">")
  end

  def test_yylex_string_pct_other
    util_lex_token("%%blah%",
                   :tSTRING_BEG, "%%",
                   :tSTRING_CONTENT, "blah",
                   :tSTRING_END, "%")
  end

  def test_yylex_string_pct_w
    util_bad_token("%w[s1 s2 ",
                   :tAWORDS_BEG,     "%w[",
                   :tSTRING_CONTENT, "s1",
                   :tSPACE,              nil,
                   :tSTRING_CONTENT, "s2",
                   :tSPACE,              nil)
  end

  def test_yylex_string_pct_w_bs_nl
    util_lex_token("%w[s1 \\\ns2]",
                   :tAWORDS_BEG,     "%w[",
                   :tSTRING_CONTENT, "s1",
                   :tSPACE,              nil,
                   :tSTRING_CONTENT, "\ns2",
                   :tSPACE,              nil,
                   :tSTRING_END,     nil)
  end

  def test_yylex_string_pct_w_bs_sp
    util_lex_token("%w[s\\ 1 s\\ 2]",
                   :tAWORDS_BEG,     "%w[",
                   :tSTRING_CONTENT, "s 1",
                   :tSPACE,              nil,
                   :tSTRING_CONTENT, "s 2",
                   :tSPACE,              nil,
                   :tSTRING_END,     nil)
  end

  def test_yylex_string_pct_w_tab
    util_lex_token("%w[abc\tdef]",
                   :tAWORDS_BEG,      "%w[",
                   :tSTRING_CONTENT, "abc\tdef",
                   :tSPACE,              nil,
                   :tSTRING_END,     nil)
  end

  def test_yylex_string_single
    util_lex_token("'string'",
                   :tSTRING, "string")
  end

  def test_yylex_string_single_escape_chars
    util_lex_token("'s\\tri\\ng'",
                   :tSTRING, "s\\tri\\ng")
  end

  def test_yylex_string_single_nl
    util_lex_token("'blah\\\nblah'",
                   :tSTRING, "blah\\\nblah")
  end

  def test_yylex_symbol
    util_lex_token(":symbol",
                   :tSYMBOL, "symbol")
  end

  def test_yylex_symbol_bad_zero
    util_bad_token(":\"blah\0\"",
                   :tSYMBEG, ":")
  end

  def test_yylex_symbol_double
    util_lex_token(":\"symbol\"",
                   :tSYMBEG, ":",
                   :tSTRING_CONTENT, "symbol",
                   :tSTRING_END, '"')
  end

  def test_yylex_symbol_single
    util_lex_token(":'symbol'",
                   :tSYMBEG, ":",
                   :tSTRING_CONTENT, "symbol",
                   :tSTRING_END, "'")
  end

  def test_yylex_ternary
    util_lex_token("a ? b : c",
                   :tIDENTIFIER, "a",
                   :tEH,         "?",
                   :tIDENTIFIER, "b",
                   :tCOLON,      ":",
                   :tIDENTIFIER, "c")

    util_lex_token("a ?bb : c", # GAH! MATZ!!!
                   :tIDENTIFIER, "a",
                   :tEH,         "?",
                   :tIDENTIFIER, "bb",
                   :tCOLON,      ":",
                   :tIDENTIFIER, "c")

    util_lex_token("42 ?", # 42 forces expr_end
                   :tINTEGER, 42,
                   :tEH,          "?")
  end

  def test_yylex_tilde
    util_lex_token "~", :tTILDE, "~"
  end

  def test_yylex_tilde_unary
    @lex.lex_state = :expr_fname
    util_lex_token "~@", :tTILDE, "~"
  end

  def test_yylex_uminus
    util_lex_token("-blah",
                   :tUMINUS, "-",
                   :tIDENTIFIER, "blah")
  end

  def test_yylex_underscore
    util_lex_token("_var", :tIDENTIFIER, "_var")
  end

  def test_yylex_underscore_end
    @lex.src = "__END__\n"
    deny @lex.advance
  end

  def test_yylex_uplus
    util_lex_token("+blah",
                   :tUPLUS, "+",
                   :tIDENTIFIER, "blah")
  end

  def test_zbug_float_in_decl
    util_lex_token("def initialize(u = ",
                   :kDEF, "def",
                   :tIDENTIFIER, "initialize",
                   :tLPAREN2, "(",
                   :tIDENTIFIER, "u",
                   :tEQL, "=")

    assert_equal :expr_beg, @lex.lex_state

    util_lex_token("0.0, s = 0.0",
                   :tFLOAT, 0.0,
                   :tCOMMA, ',',
                   :tIDENTIFIER, "s",
                   :tEQL, "=",
                   :tFLOAT, 0.0)
  end

  def test_zbug_id_equals
    util_lex_token("a =",
                   :tIDENTIFIER, "a",
                   :tEQL, "=")

    assert_equal :expr_beg, @lex.lex_state

    util_lex_token("0.0",
                   :tFLOAT, 0.0)
  end

  def test_zbug_no_spaces_in_decl
    util_lex_token("def initialize(u=",
                   :kDEF, "def",
                   :tIDENTIFIER, "initialize",
                   :tLPAREN2, "(",
                   :tIDENTIFIER, "u",
                   :tEQL, "=")

    assert_equal :expr_beg, @lex.lex_state

    util_lex_token("0.0,s=0.0",
                   :tFLOAT, 0.0,
                   :tCOMMA, ",",
                   :tIDENTIFIER, "s",
                   :tEQL, "=",
                   :tFLOAT, 0.0)
  end

  ############################################################

  def util_bad_token s, *args
    assert_raises SyntaxError do
      util_lex_token s, *args
    end
  end

  def util_escape expected, input
    @lex.src = input
    assert_equal expected, @lex.read_escape
  end

  def util_escape_bad input
    @lex.src = input
    assert_raises SyntaxError do
      @lex.read_escape
    end
  end

  def util_lex_fname name, type, end_state = :expr_arg
    @lex.lex_state = :expr_fname # can only set via parser's defs

    util_lex_token("def #{name} ", :kDEF, "def", type, name)

    assert_equal end_state, @lex.lex_state
  end

  def util_lex_token input, *args
    @lex.src = input

    until args.empty? do
      token = args.shift
      value = args.shift
      assert @lex.advance, "no more tokens"
      assert_equal [token, value], [@lex.token, @lex.yacc_value]
    end

    deny @lex.advance, "must be empty, but had #{[@lex.token, @lex.yacc_value].inspect}"
  end
end

