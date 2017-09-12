require 'test_helper'

class AuthSourceInternalControllerTest < ActionController::TestCase
  setup do
    @model = AuthSourceInternal.unscoped.first
  end

  basic_index_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

end
