require 'test_helper'

class TaxonomyHelperTest < ActionView::TestCase
  include FormHelper
  include TaxonomyHelper

  describe "all_checkbox" do
    it "resource symbol should be constantized" do
      as_admin do
        form = form_for(taxonomies(:organization1)) do |f|
          all_checkbox(f, :hostgroups)
        end
        html = Nokogiri::HTML(form)
        assert_nothing_raised do
          html.css("input[id='organization_ignore_types_hostgroup']")[0]["value"].constantize
        end
      end
    end

    it "resource symbol should be constantized" do
      user = FactoryBot.create(:user)
      filter = FactoryBot.create(:filter, :on_name_all, :permissions => [Permission.find_by_name(:view_domains)])
      user.roles << filter.role
      as_user user do
        form_for(taxonomies(:organization1)) do |f|
          refute_nil all_checkbox(f, :domains)
        end
      end
    end
  end
end
