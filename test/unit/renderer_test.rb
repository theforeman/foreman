require 'test_helper'

class RendererTest < ActiveSupport::TestCase
  include Foreman::Renderer

  test "should indent a string" do
    indented = indent 4 do
      "foo\nbar\nbaz"
    end
    assert_equal indented, "    foo\n    bar\n    baz"
  end

end
