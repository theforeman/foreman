require 'test_helper'

class CVE202633176Test < ActiveSupport::TestCase
  # CVE-2026-33176: Active Support DoS via large scientific notation strings
  # Verify that number helpers reject scientific notation strings instead of
  # expanding them into huge BigDecimal values.

  test 'number_to_currency rejects scientific notation string' do
    result = ActiveSupport::NumberHelper.number_to_currency('1e10000')
    assert_equal '$1e10000', result
  end

  test 'number_to_percentage rejects scientific notation string' do
    result = ActiveSupport::NumberHelper.number_to_percentage('1e10000')
    assert_equal '1e10000%', result
  end

  test 'number_to_currency handles normal numeric strings' do
    result = ActiveSupport::NumberHelper.number_to_currency('1234.56')
    assert_equal '$1,234.56', result
  end

  test 'number_to_currency handles strings with d as scientific notation' do
    result = ActiveSupport::NumberHelper.number_to_currency('123481223d98989')
    assert_equal '$123481223d98989', result
  end

  test 'number_to_currency handles negative scientific notation string' do
    result = ActiveSupport::NumberHelper.number_to_currency('-888E89789')
    assert_equal '-$888E89789', result
  end
end
