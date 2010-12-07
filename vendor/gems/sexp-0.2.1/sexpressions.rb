require 'rubygems'
require 'rparsec'

module SExpressionParser
  extend RParsec::Parsers

  def self.stringer(opener, closer=nil, translate={})
    closer = opener if closer.nil?
    escape = (string('\\') >> any).map do |charnum|
      escaped = charnum.chr
      translate[escaped] || escaped
    end
    open   = string(opener)
    close  = string(closer)
    other  = not_string(closer).map{|charnum| charnum.chr }
    string = (open >> (escape|other).many << close).map {|strings| strings.to_s }
  end

  Integer = integer.map{|x| x.to_i }
  Float = number.map{|x| x.to_f }
  Number = longest(Integer, Float)
  Special = Regexp.escape('+-*/=<>?!@#$%^&:~')
  Symbol = regexp(/[\w#{Special}]*[A-Za-z#{Special}][\w#{Special}]*/).map{|s| s.to_sym }
  String = stringer(%q{"}, %q{"}, "n" => "\n", "t" => "\t")
  List = char('(') >> lazy{Values} << char(')')
  Quoted = char("'") >> lazy{Value}.map{|value| [:quote, value] }
  Value = whitespace.many_ >> alt(Quoted, List, String, Symbol, Number) << whitespace.many_
  Values = Value.many
  Parser = Values << eof

  def self.parse(text)
    Parser.parse(text)
  end
end

class Object; def to_sexp; inspect(); end; end
class Symbol; def to_sexp; id2name(); end; end
class Array;  def to_sexp; "(#{map{|x| x.to_sexp }.join(' ')})"; end; end
class String; def parse_sexp; SExpressionParser.parse(self) ; end; end
