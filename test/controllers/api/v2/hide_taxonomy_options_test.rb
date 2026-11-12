require 'test_helper'

class Api::V2::HideTaxonomySimpleController < Api::V2::BaseController
  hide_taxonomy_options
end

class Api::V2::HideTaxonomyWithDescriptionController < Api::V2::BaseController
  hide_taxonomy_options

  resource_description do
    api_version 'v2'
    api_base_url '/test_plugin/api'
  end
end

class Api::V2::HideTaxonomyAfterDescriptionController < Api::V2::BaseController
  resource_description do
    api_version 'v2'
    api_base_url '/before-hide/api'
  end

  hide_taxonomy_options
end

class Api::V2::InheritedHiddenTaxonomyController < Api::V2::HideTaxonomySimpleController
  resource_description do
    api_version 'v2'
    api_base_url '/inherited/api'
  end
end

class HideTaxonomyOptionsTest < ActiveSupport::TestCase
  test 'hides taxonomy params without another resource description' do
    assert_hidden_taxonomy_params(Api::V2::HideTaxonomySimpleController)
  end

  test 'hides taxonomy params in a subsequent resource description' do
    controller = Api::V2::HideTaxonomyWithDescriptionController

    assert_hidden_taxonomy_params(controller)
    assert_equal '/test_plugin/api', controller.apipie_resource_descriptions.first._api_base_url
  end

  test 'hides taxonomy params when declared after a resource description' do
    controller = Api::V2::HideTaxonomyAfterDescriptionController

    assert_hidden_taxonomy_params(controller)
    assert_equal '/before-hide/api', controller.apipie_resource_descriptions.first._api_base_url
  end

  test 'hides taxonomy params in an inherited resource description' do
    controller = Api::V2::InheritedHiddenTaxonomyController

    assert_hidden_taxonomy_params(controller)
    assert_equal '/inherited/api', controller.apipie_resource_descriptions.first._api_base_url
  end

  private

  def assert_hidden_taxonomy_params(controller)
    params = controller.apipie_resource_descriptions.first._params_args.index_by(&:first)

    assert_equal false, params.fetch(:location_id).fetch(2).fetch(:show)
    assert_equal false, params.fetch(:organization_id).fetch(2).fetch(:show)
  end
end
