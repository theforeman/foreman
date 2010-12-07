require 'safemode'
require 'erb'

erb_code = %q{<% 10.times do |i| %><%= i %><% end %>}

raw_code = %q{
  (1..10).to_a.collect do |i|
    puts i
    i * 2
  end.join(', ')
}

box = Safemode::Box.new

puts "Doing the ERB code in safe mode\n-----"
puts box.eval(ERB.new(erb_code).src)

puts "\nDoing the regular Ruby code in safe mode\n-----"
puts box.eval(raw_code)

puts "\nOutput from regular Ruby code\n-----"
puts box.output

