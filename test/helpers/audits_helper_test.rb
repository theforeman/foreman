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

  describe ":key_to_class" do
    test "with association_name '*y' and :has_many, :key_to_class should return correct klass" do
      audit_rec = FactoryBot.build(
        :audit, :action => 'update', :auditable_type => 'DummyHostContent',
        :auditable_id => "272", :version => "1",
        :audited_changes => { "dummy_repository_ids" => [[12], [12, 3]] })
      output = key_to_class('dummy_repository_ids', audit_rec)
      assert_equal output, DummyRepository
    end

    test "with :has_many, :key_to_class should return correct klass" do
      audit_rec = FactoryBot.build(
        :audit, :action => 'update', :auditable_type => 'DummyHostContent',
        :auditable_id => "272", :version => "2",
        :audited_changes => { "dummy_org_ids" => [[1], [1, 3]] })
      output = key_to_class('dummy_org_ids', audit_rec)
      assert_equal output, DummyOrg
    end

    test 'with :has_one, :key_to_class should return correct association' do
      audit_rec = FactoryBot.build(
        :audit, :action => 'update', :auditable_type => 'DummyHostContent',
        :auditable_id => "272", :version => "3",
        :audited_changes => { "dummy_environment_id" => [1, 2] })
      output = key_to_class('dummy_environment_id', audit_rec)
      assert_equal output, DummyEnvironment
    end
  end
end
