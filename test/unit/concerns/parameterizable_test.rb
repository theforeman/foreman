# encoding: utf-8
require 'test_helper'

class ParameterizableTest < ActiveSupport::TestCase

  describe 'parameterize' do

    it 'should strip disallowed url characters and keep unicode ones' do
      assert_equal '1-žščřďťň', Parameterizable.parameterize("1-žšč!*'();:@&=+$,?%#[]řďťň")
    end

    it 'should convert slashes to dashes' do
      assert_equal '1-ž-šč-řďťň', Parameterizable.parameterize("1-ž/šč!*'();:@&=+$,/?%#[]řďťň")
    end

    it 'should strip trailing dashes' do
      assert_equal '1', Parameterizable.parameterize("1-[]")
    end

  end

end
