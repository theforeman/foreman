$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'test/unit'
require 'safemode'
require 'erb'

module TestHelper
  class << self
    def no_method_error_raising_calls
      [ 'nil.eval("a = 1")',
        'true.eval("a = 1")',
        'false.eval("a = 1")',
        '@article.is_article?.eval("a = 1")',
        '@article.comments.map{|c| c.eval("a = 1")}' ]
    end
    
    def security_error_raising_calls
      [ "class A\n end",
        'File.open("/etc/passwd")',
        '::File.open("/etc/passwd")',
        'defined? a',
        # '"#{`ls -a`}"', # hu? testing this separately, see testcase
        'alias b instance_eval',
        '@@a',
        '@@a = 1',
        '$LOAD_PATH',
        '$LOAD_PATH = 1',
        '@a = 1',
        '$1',
        'public to_s',
        'protected to_s',
        'private to_s',
        "attr_reader :a",
        'URI("http://google.com")',
        "`ls -a`", "exec('echo *')", "syscall 4, 1, 'hello', 5", "system('touch /tmp/helloworld')",
        "abort", 
        "exit(0)", "exit!(0)", "at_exit{'goodbye'}",
        "autoload(::MyModule, 'my_module.rb')",
        "binding",                                    
        "callcc{|cont| cont.call}",
        'eval %Q(send(:system, "ls -a"))',
        "fork",
        "gets", "readline", "readlines",
        "global_variables", "local_variables",
        "proc{}",
        "lambda{}",
        "load('/path/to/file')", "require 'something'",
        "loop{}",
        "open('/etc/passwd'){|f| f.read}",
        "p 'text'", "pretty_inspect",
        # "print 'text'", "puts 'text'", allowed and buffered these (see ScopeObject)
        "printf 'text'", "putc 'a'", 
        "raise RuntimeError, 'should not happen'",
        "rand(0)", "srand(0)",                           
        "set_trace_func proc{|event| puts event}", "trace_var :$_, proc {|v| puts v }", "untrace_var :$_",
        "sleep", "sleep(0)",                           
        "test(1, a, b)",                           
        "Signal.trap(0, proc { puts 'Terminating: #{$$}' })",
        "warn 'warning'" ]
    end
  end

  def assert_raise_no_method(code = nil, assigns = {}, locals = {}, &block)
    assert_raise_safemode_error(Safemode::NoMethodError, code, assigns, locals, &block)
  end

  def assert_raise_security(code = nil, assigns = {}, locals = {}, &block)
    assert_raise_safemode_error(Safemode::SecurityError, code, assigns, locals, &block)
  end
  
  def assert_raise_safemode_error(error, code, assigns = {}, locals = {})
    code = yield(code) if block_given?
    assert_raise(error, code) { safebox_eval(code, assigns, locals) }
  end
  
  def safebox_eval(code, assigns = {}, locals = {})
    # puts Safemode::Parser.jail(code)
    Safemode::Box.new.eval code, assigns, locals
  end  
end

class Article
  def is_article?
    true
  end
  
  def title
    'an article title'
  end
  
  def to_jail
    Article::Jail.new self
  end
  
  def comments
    [Comment.new(self), Comment.new(self)]
  end
end

class Comment
  attr_reader :article
  
  def initialize(article)
    @article = article
  end
  
  def text
    "comment #{object_id}"
  end
  
  def to_jail
    Comment::Jail.new self
  end
end

class Article::Jail < Safemode::Jail
  allow :title, :comments, :is_article?
  
  def author_name
    "this article's author name"
  end
end

class Article::ExtendedJail < Article::Jail
end

class Comment::Jail < Safemode::Jail
  allow :article, :text
end
