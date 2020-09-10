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

    it 'should convert dots to dashes' do
      assert_equal('1-fore-man-org', Parameterizable.parameterize('1-fore.man.org'))
      assert_equal('1-Форє-ман-орґ', Parameterizable.parameterize('1-Форє.ман.орґ'))
    end

    it 'should convert dots to dashes, yet keep spaces' do
      assert_equal('foreman ШЯЛ inc-luded', Parameterizable.parameterize('foreman ШЯЛ inc.luded'))
    end
  end
end
