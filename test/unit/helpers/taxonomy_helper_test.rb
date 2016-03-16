require 'test_helper'

class TaxonomyHelperTest < ActionView::TestCase
  include FormHelper
  include TaxonomyHelper

  describe "all_checkbox" do
    setup do
      User.current = users(:admin)
    end

    it "resource symbol should be constantized" do
      form = form_for(taxonomies(:organization1)) do |f|
        all_checkbox(f, :hostgroups)
      end
      html = Nokogiri::HTML(form)
      assert_nothing_raised do
        html.css("input[id='organization_ignore_types_hostgroup']")[0]["value"].constantize
      end
    end
  end
end
