require File.join(File.dirname(__FILE__), 'test_helper')

class TestSafemodeParser < Test::Unit::TestCase
  def test_vcall_should_be_jailed
    assert_jailed 'to_jail.a.to_jail.class', 'a.class'
  end
    
  def test_call_should_be_jailed
    assert_jailed '(1.to_jail + 1).to_jail.class', '(1 + 1).class'
  end
    
  def test_estr_should_be_jailed
    assert_jailed '"#{1.to_jail.class}"', '"#{1.class}"'
  end
    
  def test_if_should_be_usable_for_erb
    assert_jailed "if true then\n 1\nend", "if true\n 1\n end"
  end
    
  def test_if_else_should_be_usable_for_erb
    assert_jailed "if true then\n 1\n else\n2\nend", "if true\n 1\n else\n2\n end"
  end
    
  def test_ternary_should_be_usable_for_erb
    assert_jailed "if true then\n 1\n else\n2\nend", "true ? 1 : 2"
  end

  def test_output_buffer_should_be_assignable
    assert_nothing_raised do
      jail('@output_buffer = ""')
    end
  end

private
  
  def assert_jailed(expected, code)
    assert_equal expected.gsub(' ', ''), jail(code).gsub(' ', '')
  end 
  
  def jail(code)
    Safemode::Parser.jail(code)
  end
end


