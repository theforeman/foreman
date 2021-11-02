module Foreman
  module Renderer
    module DocTemplates
      module BasicRubyMethods
        module Object
          extend ApipieDSL::Module

          apipie_class 'Object', 'Methods in here can be applied to any Ruby object' do
            sections only: %w[basic_ruby_methods]
          end

          apipie_method :blank?, 'Returns true if object is blank.' do
            desc 'An object is blank if it’s false, empty, or a whitespace string.'
            returns one_of: [true, false]
            example "[1, 2].blank?    #=> false
''.blank?   #=> true"
          end

          apipie_method :present?, 'Returns true if object is not blank.' do
            desc 'An object is present unless it’s false, empty, or a whitespace string.'
            returns one_of: [true, false]
            example "[1, 2].present?    #=> true
' '.present?   #=> false"
          end

          apipie_method :to_s, 'Returns a string representing object.' do
            desc 'By default prints the object’s class and an encoding of the object id.'
            returns ::String
            example '[1, 2].to_s    #=> "[1, 2]"
user.to_s    #=> "John Doe"'
          end

          apipie_method :equal?, 'Equality — Returns true only if obj and other are the same object.' do
            desc 'Unlike #==, the equal? is used to determine object identity (that is, a.equal?(b) if and only if a is the same object as b)'
            required :other, ::Object
            returns one_of: [true, false]
            example 'obj = "a"
other = obj.dup

obj == other      #=> true
obj.equal? other  #=> false
obj.equal? obj    #=> true'
          end

          apipie_method :freeze, 'Prevents further modifications to object.' do
            desc 'There is no way to unfreeze a frozen object.'
            returns ::Object
            raises RuntimeError, 'Will be raised if modification is attempted.'
            example "str = 'Hello'
str << ', World!'    #=> FrozenError (can't modify frozen String)"
          end

          apipie_method :inspect, 'Returns a string containing a human-readable representation of object.' do
            desc 'The default inspect shows the object’s class name, an encoding of the object id,
and a list of the instance variables and their values (by calling inspect on each of them).'
            returns ::String
            example 'Time.new.inspect    #=> "2008-03-08 19:43:39 +0900"'
          end

          apipie_method :integer?, 'Returns true if given number is an Integer.' do
            returns one_of: [true, false]
            example '1.0.integer?   #=> false
1.integer?     #=> true'
          end

          apipie_method :is_a?, 'Returns true if given class is the class of obj, or if class is one of the superclasses of obj or modules included in obj.' do
            required :class, ::Class
            returns one_of: [true, false]
            aliases :kind_of?
            example 'module M;    end
class A
  include M
end
class B < A; end
class C < B; end

b = B.new
b.is_a? A          #=> true
b.is_a? B          #=> true
b.is_a? C          #=> false
b.is_a? M          #=> true
'
          end

          apipie_method :methods, 'Returns a list of the names of public and protected methods of given object.' do
            desc "This will include all the methods accessible in obj's ancestors.
If the optional parameter is false, it returns an array of obj's public and protected singleton methods,
the array will not include methods in modules included in obj."
            optional :regular, [true, false], default: true
            returns ::Array
            example 'class Klass
  def klass_method()
  end
end
k = Klass.new
k.methods[0..9]    #=> [:klass_method, :nil?, :===,
                   #    :==~, :!, :eql?
                   #    :hash, :<=>, :class, :singleton_class]
k.methods.length   #=> 56'
          end

          apipie_method :nil?, 'Returns true if object is nil' do
            desc 'Only the object nil responds true to nil?.'
            returns one_of: [true, false]
            example 'Object.new.nil?   #=> false
nil.nil?          #=> true'
          end
        end

        module Numeric
          extend ApipieDSL::Module

          apipie_class 'Numeric' do
            desc 'Methods in this class can be invoked on both `Integer` and `Float` objects'
            sections only: %w[basic_ruby_methods]
          end

          apipie_method :abs, 'Returns the absolute value of number.' do
            returns one_of: [::Integer, ::Float], desc: 'The absolute value'
            example '12.abs         #=> 12
(-34.56).abs   #=> 34.56
-34.56.abs     #=> 34.56'
          end

          apipie_method :ceil, 'Returns the smallest number greater than or equal to given number with a precision of ndigits decimal digits (default: 0).' do
            desc 'When the precision is negative, the returned value is an integer with at least `ndigits.abs` trailing zeros.
              Returns self when ndigits is zero or positive.'
            optional :ndigits, ::Integer
            returns one_of: [::Integer, ::Float]
            example '1.ceil    #=> 1
1.ceil(2)   #=> 1
18.ceil(-1)    #=> 20
(-18).ceil(-1)    #=> -10
(-1.2).ceil    #=> -1
(-2.0).ceil    #=> -2
1.234567.ceil(3)    #=> 1.235'
          end

          apipie_method :coerce, 'Returns an array with both a numeric and a big represented as Bignum objects.' do
            desc 'If `numeric` is the same type as given number, returns an array `[numeric, number]`.
              Otherwise, returns an array with both `numeric` and number represented as `Float` objects.'
            required :numeric, ::Numeric
            returns ::Array
            example '1.coerce(2.5)   #=> [2.5, 1.0]
1.2.coerce(3)   #=> [3.0, 1.2]
1.coerce(2)     #=> [2, 1]'
          end

          apipie_method :div, 'Uses / to perform division, then converts the result to an integer.' do
            desc 'Numeric does not define the `/` operator; this is left to subclasses.'
            required :numeric, ::Numeric
            returns ::Integer, desc: 'Equivalent to num.divmod(numeric)[0].'
            see 'divmod', link: 'Numeric#divmod'
          end

          apipie_method :modulo, 'Returns modulus obtained by dividing given number by numeric.' do
            required :numeric, ::Numeric
            returns ::Float, desc: 'Equivalent to num.divmod(numeric)[1].'
            see 'divmod', link: 'Numeric#divmod'
          end

          apipie_method :divmod, 'Returns an array containing the quotient and modulus obtained by dividing num by numeric.' do
            required :numeric, ::Numeric
            returns ::Array
            example '11.divmod(3)        #=> [3, 2]
11.divmod(-3)       #=> [-4, -1]
11.divmod(3.5)      #=> [3, 0.5]
(-11).divmod(3.5)   #=> [-4, 3.0]
11.5.divmod(3.5)    #=> [3, 1.0]'
          end

          apipie_method :eql?, 'Returns true if num and numeric are the same type and have equal values.' do
            desc 'Contrast this with `Numeric#==`, which performs type conversions.'
            required :numeric, ::Numeric
            returns one_of: [true, false]
            example '1 == 1.0        #=> true
1.eql?(1.0)     #=> false
1.0.eql?(1.0)   #=> true'
          end

          apipie_method :floor, 'Returns the largest number less than or equal to num with a precision of ndigits decimal digits (default: 0).' do
            optional :ndigits, ::Integer
            returns one_of: [::Integer, ::Float]
            example '1.2.floor      #=> 1
2.0.floor      #=> 2
(-1.2).floor   #=> -2
(-2.0).floor   #=> -2'
          end

          apipie_method :nonzero?, 'Returns self if given number is not zero, nil otherwise.' do
            desc 'This behavior is useful when chaining comparisons'
            returns one_of: [true, false]
            example 'a = %w( z Bb bB bb BB a aA Aa AA A )
b = a.sort {|a,b| (a.downcase <=> b.downcase).nonzero? || a <=> b }
b   #=> ["A", "a", "AA", "Aa", "aA", "BB", "Bb", "bB", "bb", "z"]'
          end

          apipie_method :quo, 'Returns the most exact division (rational for integers, float for floats).' do
            returns one_of: [::Rational, ::Float]
            example '1.quo(2)    #=> (1/2)
1.0.quo(2)    #=> 0.5'
          end

          apipie_method :reminder, 'Returns reminder obtained by dividing given number by numeric.' do
            required :numeric, ::Numeric
            returns ::Rational
            see 'divmod', link: 'Numeric#divmod'
          end

          apipie_method :round, 'Returns num rounded to the nearest value with a precision of ndigits decimal digits (default: 0).' do
            optional :ndigits, ::Integer
            returns one_of: [::Integer, ::Float]
            example '1.235.round(2)    #=> 1.24'
          end

          apipie_method :zero?, 'Returns true if num has a zero value.' do
            returns one_of: [true, false]
            see 'nonzero?', link: 'Numeric#nonzero?'
          end

          apipie_method :truncate, 'Returns num truncated (toward zero) to a precision of ndigits decimal digits (default: 0).' do
            desc 'When the precision is negative, the returned value is an integer with at least `ndigits.abs` trailing zeros.
Returns a floating point number when `ndigits` is positive, otherwise returns an integer.'
            optional :ndigits, ::Integer
            returns one_of: [::Integer, ::Float]
            example '2.8.truncate           #=> 2
(-2.8).truncate        #=> -2
1.234567.truncate(2)   #=> 1.23
34567.89.truncate(-2)  #=> 34500'
          end
        end

        module Integer
          extend ApipieDSL::Module

          apipie_class 'Integer' do
            sections only: %w[basic_ruby_methods]
          end

          apipie_method :id2name, 'Returns the name of the object whose symbol id is fix.' do
            desc 'If there is no symbol in the symbol table with this value, returns nil.
              id2name has nothing to do with the Object.id method.'
            returns one_of: [::String, nil], desc: 'The name of the object.'
            example "symbol = :@inst_var    #=> :@inst_var
id     = symbol.to_i   #=> 9818
id.id2name             #=> '@inst_var'"
          end

          apipie_method :chr, "Returns a string containing the character represented by the int's value according to encoding." do
            optional :encoding, ::Encoding
            returns ::String
            example '65.chr    #=> "A"
230.chr   #=> "\xE6"
255.chr(Encoding::UTF_8)   #=> "\u00FF"'
          end

          apipie_method :downto, 'Iterates the given block, passing in decreasing values from given integer down to and including limit.' do
            required :limit, ::Integer
            block 'Optional. If no block is given, an enumerator is returned instead.', schema: '{ |i| block }'
            returns one_of: [::Integer, ::Enumerator]
            example '5.downto(1) { |n| print n, ".. " }
puts "Liftoff!"
#=> "5.. 4.. 3.. 2.. 1.. Liftoff!"'
          end

          apipie_method :next, 'Returns the successor of given integer, i.e. the Integer equal to int+1.' do
            returns ::Integer
            aliases :succ
            example '1.next      #=> 2
(-1).next   #=> 0'
          end

          apipie_method :size, 'Returns the number of bytes in the machine representation of given integer (machine dependent).' do
            returns ::Integer
            example '1.size               #=> 8
-1.size              #=> 8
2147483647.size      #=> 8
(256**10 - 1).size   #=> 10'
          end

          apipie_method :times, 'Iterates the given block given integer times, passing in values from zero to int - 1.' do
            block 'Optional. If no block is given, an enumerator is returned instead.', schema: '{ |i| block }'
            aliases :each
            returns ::Integer
            example '5.times {|i| print i, " " }   #=> 0 1 2 3 4'
          end

          apipie_method :upto, 'Iterates the given block, passing in integer values from given integer up to and including `limit`.' do
            block 'Optional. If no block is given, an enumerator is returned instead.', schema: '{ |i| block }'
            returns ::Integer
            example '5.upto(10) {|i| print i, " " }   #=> 5 6 7 8 9 10'
          end

          apipie_method :to_f, "Converts int to a Float. If int doesn't fit in a Float, the result is infinity." do
            returns ::Float
            example '1.to_f    #=> 1.0'
          end
        end

        module Float
          extend ApipieDSL::Module

          apipie_class 'Float' do
            sections only: %w[basic_ruby_methods]
          end

          apipie_method :finite?, 'Returns true if float is a valid IEEE floating point number, i.e. it is not infinite and #nan? is false.' do
            returns one_of: [true, false]
          end

          apipie_method :nan?, 'Returns true if float is an invalid IEEE floating point number.' do
            returns one_of: [true, false]
          end

          apipie_method :infinite?, 'Returns nil, -1, or 1 depending on whether the value is finite, -Infinity, or +Infinity.' do
            returns one_of: [-1, 1, nil]
          end

          apipie_method :to_i, 'Returns the float truncated to an Integer.' do
            returns ::Integer
            aliases :to_int
            example '1.2.to_i      #=> 1
(-1.2).to_i   #=> -1'
          end
        end

        module Array
          extend ApipieDSL::Module

          apipie_class 'Array' do
            sections only: %w[basic_ruby_methods]
          end

          apipie_method :[], 'Returns the element at index, or returns a subarray starting at the start index and continuing for length elements, or returns a subarray specified by range of indices.' do
            desc 'Negative indices count backward from the end of the array (-1 is the last element).
For start and range cases the starting index is just before an element.
Additionally, an empty array is returned when the starting index for an element range is at the end of the array.'
            signature '[]', '[index]', '[start, length]', '[range]'
            required :index, ::Integer
            optional :start, ::Integer, 'Used in pair with length parameter'
            optional :length, ::Integer, 'Used in pair with start parameter'
            optional :range, ::Range
            returns one_of: [::Object, ::Array, nil], desc: 'Returns nil if the index (or starting index) are out of range.'
            example 'a = [ "a", "b", "c", "d", "e" ]
a[2] +  a[0] + a[1]    #=> "cab"
a[6]                   #=> nil
a[1, 2]                #=> [ "b", "c" ]
a[1..3]                #=> [ "b", "c", "d" ]'
          end

          apipie_method :[]=, 'Sets the element at index, or replaces a subarray from the start index for length elements, or replaces a subarray specified by the range of indices.' do
            desc 'If indices are greater than the current capacity of the array, the array grows automatically.
Elements are inserted into the array at start if length is zero. Negative indices will count backward from the end of the array.
For start and range cases the starting index is just before an element.'
            signature '[]=', '[index]=', '[start, length]=', '[range]='
            required :index, ::Integer
            optional :start, ::Integer, 'Used in pair with length parameter'
            optional :length, ::Integer, 'Used in pair with start parameter'
            optional :range, ::Range
            raises IndexError, 'IndexError is raised if a negative index points past the beginning of the array'
            returns one_of: [::Object, ::Array, nil]
            example "a = Array.new
a[4] = '4';                 #=> [nil, nil, nil, nil, '4']
a[0, 3] = [ 'a', 'b', 'c' ] #=> ['a', 'b', 'c', nil, '4']
a[1..2] = [ 1, 2 ]          #=> ['a', 1, 2, nil, '4']"
          end

          apipie_method :map, 'Returns a new array with the results of running block once for every element in enum.' do
            block 'Optional. If no block is given, an enumerator is returned instead.', schema: '{ |obj| block }'
            returns ::Array, desc: 'New array with the results of running block'
            example "(1..4).map { |i| i*i }      #=> [1, 4, 9, 16]"
          end

          apipie_method :any?, 'Passes each element of the collection to the given block.' do
            desc 'The method returns true if the block ever returns a value other than false or nil.
If the block is not given, Ruby adds an implicit block of { |obj| obj } that will cause any? to return true if at least one of the collection members is not false or nil.'
            block 'Optional. If no block is given, an enumerator is returned instead.', schema: '{ |obj| block }'
            returns one_of: [true, false]
            example '[nil, true, 99].any?(Integer)    #=> true'
          end

          apipie_method :assoc, 'Searches through an array whose elements are also arrays comparing obj with the first element of each contained array using obj.==.' do
            desc 'Returns the first contained array that matches (that is, the first associated array), or nil if no match is found.'
            required :obj, ::Object
            returns one_of: [::Array, nil]
            example 's1 = [ "colors", "red", "blue", "green" ]
s2 = [ "letters", "a", "b", "c" ]
s3 = "foo"
a  = [ s1, s2, s3 ]
a.assoc("letters")  #=> [ "letters", "a", "b", "c" ]
a.assoc("foo")      #=> nil'
          end

          apipie_method :at, 'Returns the element at index.' do
            desc 'A negative index counts from the end of self. Returns nil if the index is out of range.'
            required :index, ::Integer
            returns one_of: [::Object, nil]
            see '[]', link: 'Array#[]'
          end

          apipie_method :collect, 'Returns a new array with the results of running block once for every element in given array.' do
            block 'Optional. If no block is given, an enumerator is returned instead.', schema: '{ |obj| block }'
            returns ::Array
            example '(1..4).collect { |i| i*i }      #=> [1, 4, 9, 16]'
          end

          apipie_method :compact, 'Returns a copy of given array with all nil elements removed.' do
            returns ::Array
            example '[ "a", nil, "b", nil, "c", nil ].compact    #=> [ "a", "b", "c" ]'
          end

          apipie_method :concat, 'Appends the elements of passed arrays to given array.' do
            list :arrays
            returns ::Array
            example '[ "a" ].concat( ["b"], ["c", "d"] )    #=> [ "a", "b", "c", "d" ]'
          end

          apipie_method :delete, 'Deletes all items from given array that are equal to passed object.' do
            desc 'Returns the last deleted item, or nil if no matching item is found.'
            required :obj, ::Object
            block 'Optional. If the code block is given, the result of the block is returned if the item is not found.', schema: '{ block }'
            returns one_of: [::Object, nil]
            example 'a = [ "a", "b", "b", "b", "c" ]
a.delete("b")                   #=> "b"
a                               #=> ["a", "c"]'
          end

          apipie_method :delete_at, 'Deletes the element at the specified index.' do
            desc 'Returns deleted element, or nil if the index is out of range.'
            required :index, ::Integer
            returns one_of: [::Object, nil]
            example 'a = ["ant", "bat", "cat", "dog"]
a.delete_at(2)    #=> "cat"
a                 #=> ["ant", "bat", "dog"]'
          end

          apipie_method :delete_if, 'Deletes every element of given array for which block evaluates to true.' do
            desc 'The array is changed instantly every time the block is called, not after the iteration is over.'
            block 'Optional. If no block is given, an Enumerator is returned instead.', schema: '{ |item| block }'
            returns ::Array
            example 'scores = [ 97, 42, 75 ]
scores.delete_if {|score| score < 80 }   #=> [97]'
          end

          apipie_method :each, 'Calls the given block once for each element in given array, passing that element as a parameter.' do
            block 'Optional. If no block is given, an Enumerator is returned.', schema: '{ |item| block }'
            returns ::Array, desc: 'Returns the given array itself.'
            example 'a = [ "a", "b", "c" ]
a.each {|x| print x, "," }    #=> a,b,c'
          end

          apipie_method :each_index, 'Same as #each, but passes the index of the element instead of the element itself.' do
            block 'Optional. If no block is given, an Enumerator is returned.', schema: '{ |index| block }'
            returns ::Array, desc: 'Returns the given array itself.'
            example 'a = [ "a", "b", "c" ]
a.each_index {|x| print x, "," }    #=> 0,1,2'
          end

          apipie_method :empty?, 'Returns true if given array contains no elements.' do
            returns one_of: [true, false]
            example '[].empty?   #=> true'
          end

          apipie_method :fetch, 'Tries to return the element at position index.' do
            required :index, ::Integer
            optional :default, ::Object, desc: 'IndexError can be prevented by supplying this argument, which will act as a default value'
            block 'Optional. If a block is given it will only be executed when an invalid index is referenced.', schema: '{ |index| block }'
            raises IndexError, 'Throws an exception if the referenced index lies outside of the array bounds'
            returns ::Object
            example 'a = [ 11, 22, 33, 44 ]
a.fetch(1)               #=> 22
a.fetch(-1)              #=> 44
a.fetch(4, "cat")        #=> "cat"'
          end
        end

        module Hash
          extend ApipieDSL::Module

          apipie_class 'Array' do
            sections only: %w[basic_ruby_methods]
          end

          apipie_method :to_json, 'Returns a JSON string representing the hash.' do
            returns ::String
            example '{ id: 1, name: "test" }.to_json  #=> {"id":"1","name":"test"}'
          end

          apipie_method :compact, 'Returns a new hash with the nil values/key pairs removed.' do
            returns ::String
            example '{ id: 1, name: nil }.compact  #=> { id: 1 }'
          end
        end
      end
    end
  end
end
