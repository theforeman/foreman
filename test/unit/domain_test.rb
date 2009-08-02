require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  test "should not save without a name" do
    domain = Domain.new
    assert !domain.save
  end

end
