require 'test_helper'

class DummyDestroyFlagClass
  cattr_accessor :callbacks

  def self.before_destroy(&block)
    self.callbacks = [block]
  end

  def destroy
    self.class.callbacks.each do |callback|
      callback.call(self)
    end
  end

  include DestroyFlag
end

class DestroyFlagTest < ActiveSupport::TestCase
  describe 'include DestroyFlag' do
    setup do
      @dummy = DummyDestroyFlagClass.new
    end

    test "it sets the flag" do
      refute @dummy.being_destroyed?
      @dummy.destroy
      assert @dummy.being_destroyed?
    end
  end
end
