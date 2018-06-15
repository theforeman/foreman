require 'test_helper'

class ExpirableTest < ActiveSupport::TestCase
  class SampleModel
    class << self
      def scope(name, opts)
      end
    end

    include Expirable

    attr_accessor :expires_at
  end

  let(:sample) { SampleModel.new }

  test '#expires? is false if no expiration is set' do
    assert_equal false, sample.expires?
  end

  test '#expires? is true if expiration is set' do
    sample.expires_at = Time.current
    assert_equal true, sample.expires?
  end
end
