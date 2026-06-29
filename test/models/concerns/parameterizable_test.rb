require 'test_helper'

class ParameterizableTest < ActiveSupport::TestCase
  describe 'ByIdName.from_param' do
    # Regression: /\A\d+-/.match?(id) raises TypeError when id is an Integer.
    # The old id =~ /\A\d+-/ form returned nil for integers (via deprecated
    # Integer#=~), allowing resource_finder to fall through to scope.find(id).
    it 'returns nil for an integer id instead of raising' do
      assert_nil Architecture.from_param(1)
    end
  end

  describe 'FindCommon#resource_finder' do
    # The nil return from from_param is intentional: resource_finder falls back
    # to scope.find(id) when from_param returns nil, so integer ids still resolve.
    it 'finds a record by integer id via the from_param fallback' do
      arch = FactoryBot.create(:architecture)
      finder = Object.new.extend(FindCommon)
      assert_equal arch, finder.resource_finder(Architecture.where(id: arch.id), arch.id)
    end
  end

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
