##
# Unique creates unique variable names.

class Unique
  def self.reset # mostly for testing
    @@curr = 0
  end

  def self.next
    @@curr += 1
    "temp_#{@@curr}".intern
  end

  reset
end
