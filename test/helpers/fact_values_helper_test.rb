require 'test_helper'

class FactValuesHelperTest < ActionView::TestCase
  include FactValuesHelper
  include ERB::Util

  def test_fact_name_with_escaped_HTML
    fact_name = FactName.create(:name => "<s></s>")
    host = Host.create(:name => "host-with-facts")
    fact_value = FactValue.create(:value => "\"h\"", :fact_name_id => fact_name.id, :host_id => host.id)
    assert_equal "<li><a title=\"Show &lt;s&gt;&lt;/s&gt; fact values for all hosts\" href=\"/fact_values?search=name+%3D+%3Cs%3E%3C%2Fs%3E\">&lt;s&gt;&lt;/s&gt;</a></li>", fact_name(fact_value, '')
  end
end
