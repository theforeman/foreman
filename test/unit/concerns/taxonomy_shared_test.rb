require 'test_helper'

class TaxonomySharedTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test ".my_taxonomies returns all taxonomies for admin" do
    as_admin do
      assert_equal Location.unscoped.pluck(:id).sort,
                   Location.my_locations.pluck(:id).sort
    end
  end

  test ".my_taxonomies returns user's associated taxonomies and children" do
    taxonomy1 = Location.create(:name => 'foo')
    taxonomy2 = Location.create(:name => 'bar', :parent => taxonomy1)
    user = FactoryGirl.create(:user, :locations => [taxonomy1])
    as_user(user) do
      assert_equal [taxonomy1.id, taxonomy2.id].sort,
                    Location.my_locations.pluck(:id).sort
    end
  end

  test "it should clone taxonomy with all associations" do
    taxonomy = Location.create(:name => 'foo')
    taxonomy_dup = taxonomy.dup
    taxonomy_dup.name = "taxonomy_dup_name"
    assert taxonomy_dup.save
    assert_equal taxonomy_dup.environment_ids, taxonomy.environment_ids
    assert_equal taxonomy_dup.hostgroup_ids, taxonomy.hostgroup_ids
    assert_equal taxonomy_dup.subnet_ids, taxonomy.subnet_ids
    assert_equal taxonomy_dup.domain_ids, taxonomy.domain_ids
    assert_equal taxonomy_dup.medium_ids, taxonomy.medium_ids
    assert_equal taxonomy_dup.user_ids, taxonomy.user_ids
    assert_equal taxonomy_dup.smart_proxy_ids.sort, taxonomy.smart_proxy_ids.sort
    assert_equal taxonomy_dup.config_template_ids, taxonomy.config_template_ids
    assert_equal taxonomy_dup.compute_resource_ids, taxonomy.compute_resource_ids
    assert_equal taxonomy_dup.realm_ids, taxonomy.realm_ids
    assert_equal taxonomy_dup.organization_ids, taxonomy.organization_ids
  end
end
