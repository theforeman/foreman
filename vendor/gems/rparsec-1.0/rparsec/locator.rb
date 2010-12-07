require 'rparsec/misc'

module RParsec
  
class CodeLocator
  extend DefHelper
  
  def_readable :code
  
  LF = ?\n
  
  def locate(ind)
    return _locateEof if ind >= code.length
    line, col = 1,1
    return line,col if ind<=0
    for i in (0...ind)
      c = code[i]
      if c == LF
        line, col = line+1, 1
      else
        col = col+1
      end
    end
    return line, col
  end
  
  def _locateEof
    line, col = 1, 1
    code.each_byte do |c|
      if c == LF
        line, col = line+1, 1 
      else
        col = col+1
      end
    end
    return line, col
  end
end

end # module