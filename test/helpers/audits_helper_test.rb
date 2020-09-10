require 'test_helper'

class DummyHostContent < ApplicationRecord
  has_many :dummy_repositories
  has_many :dummy_orgs
  has_one :dummy_environment
end

class DummyOrg < ApplicationRecord
  belongs_to :dummy_host_content
end

class DummyEnvironment < ApplicationRecord
  belongs_to :dummy_host_content
end

class DummyRepository < ApplicationRecord
  belongs_to :dummy_host_content
end

class AuditsHelperTest < ActionView::TestCase
  include AuditsHelper

  describe ":key_to_association_class" do
    test "with association_name '*y' and :has_many, :key_to_association_class should return correct klass" do
      assert_equal key_to_association_class('dummy_repository_ids', DummyHostContent), DummyRepository
    end

    test "with :has_many, :key_to_association_class should return correct klass" do
      assert_equal key_to_association_class('dummy_org_ids', DummyHostContent), DummyOrg
    end

    test 'with :has_one, :key_to_association_class should return correct association' do
      assert_equal key_to_association_class('dummy_environment_id', DummyHostContent), DummyEnvironment
    end
  end
end
