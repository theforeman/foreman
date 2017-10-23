require 'test_helper'

module Host
  class ManagedTest < ActiveSupport::TestCase
    describe 'validations' do
      subject do
        FactoryBot.build(:host, :managed)
      end
      should validate_uniqueness_of(:uuid)
    end
  end
end
