require 'test_helper'

class TaxonomyTest < ActiveSupport::TestCase
  def setup
    SETTINGS.stubs(:[]).with(:organizations_enabled).returns(true)
    SETTINGS.stubs(:[]).with(:locations_enabled).returns(false)
  end

  test '.enabled?' do
    assert Taxonomy.enabled?(:organization)
    refute Taxonomy.enabled?(:location)
  end

  test '.locations_enabled' do
    refute Taxonomy.locations_enabled
  end

  test '.organizations_enabled' do
    assert Taxonomy.organizations_enabled
  end
end
