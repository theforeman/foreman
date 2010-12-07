require File.join(File.dirname(__FILE__), 'test_helper')

class TestSafemodeEval < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @box = Safemode::Box.new
    @locals = { :article => Article.new }
    @assigns = { :article => Article.new }
    @erb_parse = lambda {|code| ERB.new("<%= #{code} %>").src }
  end

  def test_some_stuff_that_should_work
    ['"test".upcase', '10.succ', '10.times{}', '[1,2,3].each{|a| a + 1}', 'true ? 1 : 0', 'a = 1'].each do |code|
      code = ERB.new("<%= #{code} %>").src
      assert_nothing_raised{ @box.eval code }
    end
  end
  
  def test_should_turn_assigns_to_jails
    assert_raise_no_method "@article.system", @assigns, &@erb_parse
  end
  
  def test_should_turn_locals_to_jails
    code = @erb_parse.call "article.system"
    assert_raise(Safemode::NoMethodError){ @box.eval code, {}, @locals }
  end
  
  def test_should_allow_method_access_on_assigns
    code = @erb_parse.call "@article.title"
    assert_nothing_raised{ @box.eval code, @assigns }
  end
  
  def test_should_allow_method_access_on_locals
    code = @erb_parse.call "article.title"
    assert_nothing_raised{ @box.eval code, {}, @locals }
  end
  
  def test_should_not_raise_on_if_using_return_values
    code = @erb_parse.call "if @article.is_article?\n 1\n end"
    assert_nothing_raised{ @box.eval code, @assigns }
  end
  
  def test_should_work_with_if_using_return_values
    code = @erb_parse.call "if @article.is_article? then 1 end"
    assert_equal @box.eval(code, @assigns), "1" # ERB calls to_s on the result of the if block
  end
  
  def test__FILE__should_not_render_filename
    code = @erb_parse.call "__FILE__"
    assert_equal '(string)', @box.eval(code)
  end
  
  def test_interpolated_xstr_should_raise_security
    assert_raise_security '"#{`ls -a`}"'
  end  
        
  TestHelper.no_method_error_raising_calls.each do |call|
    call.gsub!('"', '\\\\"')
    class_eval %Q(
      def test_calling_#{call.gsub(/[\W]/, '_')}_should_raise_no_method
        assert_raise_no_method "#{call}"
      end
    )
  end
  
  TestHelper.security_error_raising_calls.each do |call|
    call.gsub!('"', '\\\\"')
    class_eval %Q(
      def test_calling_#{call.gsub(/[\W]/, '_')}_should_raise_security
        assert_raise_security "#{call}"
      end
    )
  end  

end