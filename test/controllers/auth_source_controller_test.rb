require 'test_helper'

class AuthSourceControllerTest < ActionController::TestCase
  setup do
    @model = AuthSource.unscoped.first
  end

  basic_index_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

end
