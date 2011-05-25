require 'test_helper'

class TFTPOrchestrationTest < ActiveSupport::TestCase
  def test_host_should_have_tftp
    if unattended?
      h = hosts(:one)
      assert h.valid?
      assert h.tftp != nil
      assert h.tftp?
    end
  end

  def test_host_should_not_have_tftp
    if unattended?
      h = hosts(:minimal)
      assert h.valid?
      assert_equal h.tftp, nil
      assert_equal h.tftp?, false
    end
  end

  def test_generate_pxe_template
    if unattended?
      h = hosts(:one)
      as_admin { h.update_attribute :operatingsystem, operatingsystems(:centos5_3) }
      h.request_url = "ahost.com:3000"

      template = h.send('generate_pxe_template').split("~")
      expected = File.open(Pathname.new(__FILE__).parent + "pxe_template").readlines.map(&:strip)
      assert_equal template,expected
    end
  end
end
