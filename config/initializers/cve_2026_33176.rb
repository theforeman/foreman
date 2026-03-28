# Backport fix for CVE-2026-33176: Active Support DoS via large scientific notation strings
#
# BigDecimal accepts scientific notation (e.g. '1e10000'), which expands into
# extremely large decimal representations causing excessive memory allocation
# and CPU consumption when formatted by number helpers.
#
# Rails 7.0 is no longer maintained upstream. This backports the fix from Rails 7.2+.
#
# Upstream commit: https://github.com/rails/rails/commit/ebd6be18120d1136511eb516338e27af25ac0a1a
# Advisory: https://github.com/rails/rails/security/advisories/GHSA-2j26-frm8-cmj9

require 'active_support/number_helper/number_converter'

module ActiveSupport
  module NumberHelper
    class NumberConverter
      private

      def valid_bigdecimal
        case number
        when Float, Rational
          number.to_d(0)
        when String
          BigDecimal(number, exception: false) unless number.to_s.match?(/[de]/i)
        else
          number.to_d rescue nil
        end
      end
    end
  end
end
