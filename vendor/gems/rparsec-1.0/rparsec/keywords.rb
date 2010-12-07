require 'rparsec/parser'

module RParsec
  
#
# This class helps building lexers and parsers for keywords.
# 
class Keywords
  extend Parsers
  
  private_class_method :new
  
  #
  # The symbol used to identify a keyword token
  #
  attr_reader :keyword_symbol
  
  #
  # The lexer that parses all the keywords represented
  #
  attr_reader :lexer
  
  #
  # Do we lex case sensitively?
  # 
  def case_sensitive?
    @case_sensitive
  end
  
  #
  # To create an instance that lexes the given keywords
  # case sensitively. 
  # _default_lexer_ is used to lex a token first, the token text is then compared with
  # the given keywords. If it matches any of the keyword, a keyword token is generated instead
  # using _keyword_symbol_.
  # The _block_ parameter, if present, is used to convert the token text to another object
  # when the token is recognized during grammar parsing phase.
  # 
  def self.case_sensitive(words, default_lexer=word.token(:word), keyword_symbol=:keyword, &block)
    new(words, true, default_lexer, keyword_symbol, &block)
  end
  
  #
  # To create an instance that lexes the given keywords
  # case insensitively. 
  # _default_lexer_ is used to lex a token first, the token text is then compared with
  # the given keywords. If it matches any of the keyword, a keyword token is generated instead
  # using _keyword_symbol_.
  # The _block_ parameter, if present, is used to convert the token text to another object
  # when the token is recognized during parsing phase.
  # 
  def self.case_insensitive(words, default_lexer=word.token(:word), keyword_symbol=:keyword, &block)
    new(words, false, default_lexer, keyword_symbol, &block)
  end
  
  # scanner has to return a string
  def initialize(words, case_sensitive, default_lexer, keyword_symbol, &block)
    @default_lexer, @case_sensitive, @keyword_symbol = default_lexer, case_sensitive, keyword_symbol
    # this guarantees that we have copy of the words array and all the word strings.
    words = copy_words(words, case_sensitive)
    @name_map = {}
    @symbol_map = {}
    word_map = {}
    words.each do |w|
      symbol = "#{keyword_symbol}:#{w}".to_sym
      word_map[w] = symbol
      parser = Parsers.token(symbol, &block)
      @symbol_map["#{w}".to_sym] = parser
      @name_map[w] = parser
    end
    @lexer = make_lexer(default_lexer, word_map)
  end
  
  #
  # Get the parser that recognizes the token of the given keyword during the parsing phase.
  #
  def parser(key)
    result = nil
    if key.kind_of? String
      name = canonical_name(key)
      result = @name_map[name]
    else
      result = @symbol_map[key]
    end
    raise ArgumentError, "parser not found for #{key}" if result.nil?
    result
  end
  
  alias [] parser
  
  private
  
  def make_lexer(default_lexer, word_map)
    default_lexer.map do |tok|
      text,ind = tok.text, tok.index
      key = canonical_name(text)
      my_symbol = word_map[key]
      case when my_symbol.nil? then tok
        else Token.new(my_symbol, text, ind) end
    end
  end
  
  def canonical_name(name)
    case when @case_sensitive then name else name.downcase end
  end
  
  def copy_words(words, case_sensitive)
    words.map do |w|
      case when case_sensitive then w.dup else w.downcase end
    end
  end
end

end # module