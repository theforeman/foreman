require 'test_helper'

class TFTPOrchestrationTest < ActiveSupport::TestCase
  def test_host_should_have_tftp
    h = hosts(:one)
    assert h.valid?
    assert h.tftp != nil
    assert h.tftp?
  end

  def test_host_should_not_have_tftp
    h = hosts(:minimal)
    assert h.valid?
    assert_equal h.tftp, nil
    assert_equal h.tftp?, false
  end

end
