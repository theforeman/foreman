require 'test_helper'

class DummyClonable
  include SelectiveClone

  include_in_clone [:a, :b]
  exclude_from_clone [:c, :d]
end

class SelectiveCloneTest < ActiveSupport::TestCase
  describe 'include SelectiveClone' do
    setup do
      @dummy = DummyClonable.new
    end

    test "it uses deep_clone with parameters specified in class" do
      @dummy.expects(:deep_clone) do |actual|
        assert_equal [:a, :b], actual[:include]
        assert_equal [:c, :d], actual[:except]
        true
      end

      @dummy.selective_clone
    end

    test "it uses deep_clone with parameters specified in class" do
      @dummy.class_eval do
        include_in_clone [:e]
        exclude_from_clone [:f]
      end

      @dummy.expects(:deep_clone) do |actual|
        assert_equal [:a, :b, :e], actual[:include]
        assert_equal [:c, :d, :f], actual[:except]
        true
      end

      @dummy.selective_clone
    end
  end
end
