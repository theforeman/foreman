require 'test_helper'

class AuthSourceExternalHelperTest < ActionView::TestCase
  include AuthSourceExternalHelper
  include TaxonomyHelper

  describe 'tab_classes_for_edit_auth_source_external' do
    context 'user with view_locations and view_organizations permission' do
      it 'returns class for location tab' do
        as_admin do
          assert_equal ({ :location => 'active' }), tab_classes_for_edit_auth_source_external
        end
      end
    end

    context 'user with view_locations permission only' do
      it 'returns class for location tab' do
        setup_user 'view', 'locations'
        assert_equal ({ :location => 'active' }), tab_classes_for_edit_auth_source_external
      end
    end

    context 'user with view_organizations permission only' do
      it 'returns class for organization tab' do
        setup_user 'view', 'organizations'
        assert_equal ({ :organization => 'active' }), tab_classes_for_edit_auth_source_external
      end
    end

    context 'user with neither view_locations nor view_organization access' do
      it 'returns a empty hash' do
        setup_user 'none'
        assert_empty tab_classes_for_edit_auth_source_external
      end
    end
  end
end
