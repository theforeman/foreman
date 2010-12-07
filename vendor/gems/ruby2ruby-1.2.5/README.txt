= ruby2ruby

* http://seattlerb.rubyforge.org/
* http://rubyforge.org/projects/seattlerb

== DESCRIPTION:

ruby2ruby provides a means of generating pure ruby code easily from
RubyParser compatible Sexps. This makes making dynamic language
processors in ruby easier than ever!

== FEATURES/PROBLEMS:
  
* Clean, simple SexpProcessor generates ruby code from RubyParser compatible sexps.

== SYNOPSYS:

    require 'rubygems'
    require 'ruby2ruby'
    require 'ruby_parser'
    require 'pp'
    
    ruby      = "def a\n  puts 'A'\nend\n\ndef b\n  a\nend"
    parser    = RubyParser.new
    ruby2ruby = Ruby2Ruby.new
    sexp      = parser.process(ruby)
    
    pp sexp

    p ruby2ruby.process(sexp)
    
    ## outputs:

    s(:block,
     s(:defn,
      :a,
      s(:args),
      s(:scope, s(:block, s(:call, nil, :puts, s(:arglist, s(:str, "A")))))),
     s(:defn, :b, s(:args), s(:scope, s(:block, s(:call, nil, :a, s(:arglist))))))
    "def a\n  puts(\"A\")\nend\ndef b\n  a\nend\n"

== REQUIREMENTS:

+ sexp_processor
+ ruby_parser

== INSTALL:

+ sudo gem install ruby2ruby

== LICENSE:

(The MIT License)

Copyright (c) Ryan Davis, Seattle.rb

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
