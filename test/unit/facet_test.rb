require 'test_helper'

class TestFacet < HostFacets::Base
end

class TestHostgroupFacet < ApplicationRecord
  include Facets::HostgroupFacet
end

class TestHostAndHostrgoupFacet < ApplicationRecord
  include Facets::HostgroupFacet
  include Facets::Base
end

module TestModule
  class ModuleTestFacet < HostFacets::Base
  end
end

class FacetTest < ActiveSupport::TestCase
  setup do
    @config = {}
    Facets.stubs(:configuration).returns(@config)
  end

  teardown do
    Host::Managed.cloned_parameters[:include].delete(:test_model)
    Host::Managed.cloned_parameters[:include].delete(:test_facet)
    Host::Managed.cloned_parameters[:include].delete(:namespaced_facet)
    Host::Managed.cloned_parameters[:include].delete(:hostgroup_facet)
    Host::Managed.cloned_parameters[:include].delete(:same_facet)

    Hostgroup.cloned_parameters[:include].delete(:test_model)
    Hostgroup.cloned_parameters[:include].delete(:test_facet)
    Hostgroup.cloned_parameters[:include].delete(:namespaced_facet)
    Hostgroup.cloned_parameters[:include].delete(:hostgroup_facet)
    Hostgroup.cloned_parameters[:include].delete(:same_facet)
  end

  context 'namespaced facets' do
    setup do
      Facets.register TestModule::ModuleTestFacet, :namespaced_facet

      @host = Host::Managed.new
      @facet = @host.build_namespaced_facet
    end

    test 'can create a namespaced facet' do
      assert_equal @facet, @host.facets.first
    end

    test 'returns facets attributes' do
      attributes = @host.attributes

      assert_not_nil attributes["namespaced_facet_attributes"]
    end
  end

  context 'managed host behavior' do
    setup do
      Facets.register TestFacet

      @host = Host::Managed.new
      @facet = @host.build_test_facet
    end

    test 'registered facets are subscribed properly' do
      assert_equal @facet, @host.facets.first
    end

    test 'facets are cloned to the new host' do
      facet_clone = @facet.dup
      @facet.stubs(:dup).returns(facet_clone)

      cloned_host = @host.clone

      assert_equal facet_clone, cloned_host.test_facet
      assert_equal facet_clone, cloned_host.facets.first
    end

    test 'facets are included in attributes' do
      attributes = @host.attributes

      assert_not_nil attributes["test_facet_attributes"]
    end

    test 'apply_inherited_attributes is augmented by facets' do
      attributes = { 'hostgroup_id' => 1 }
      @host.hostgroup = Hostgroup.new(:id => 1)

      TestFacet.expects(:inherited_attributes).returns({ :test_attribute => :test_value })
      actual_attributes = @host.apply_inherited_attributes(attributes)

      assert_equal :test_value, actual_attributes['test_facet_attributes'][:test_attribute]
    end

    test 'apply_inherited_attributes works facet defaults' do
      attributes = { 'hostgroup_id' => 1 }
      @host.hostgroup = Hostgroup.new(:id => 1)

      @host.apply_inherited_attributes(attributes)
    end

    test 'facet attributes are passed to Facet.inherited_attributes' do
      attributes = {  'hostgroup_id' => 1, 'test_facet_attributes' => { :test_attribute => :test_value }}
      @host.hostgroup = Hostgroup.new

      TestFacet.expects(:inherited_attributes).with do |hostgroup, facet_attributes|
        facet_attributes[:test_attribute] == :test_value
      end

      @host.apply_inherited_attributes(attributes)
    end

    test 'facts are parsed by facets too' do
      TestFacet.expects(:populate_fields_from_facts)
      @host.stubs(:save)
      facts_json = read_json_fixture('facts/brslc022.facts.json')

      HostFactImporter.new(@host).parse_facts(facts_json['facts'], nil, nil)
    end
  end

  context "managed host facet behavior" do
    setup do
      TestFacet.class_eval do
        def my_attribute
        end

        def my_attribute=(val)
        end
      end

      Facets.register TestFacet
    end

    test 'facets are updated without specifying id explicitly' do
      saved_host = FactoryBot.build(:host)
      saved_host.build_test_facet
      saved_host.save!
      saved_host.attributes = {'test_facet_attributes' => { 'my_attribute' => 'my_value'}}
      assert_not_nil saved_host.test_facet.id
    end

    test 'facets do not get created for nil attributes and viceversa' do
      saved_host = FactoryBot.build(:host)

      saved_host.update({'test_facet_attributes' => { 'my_attribute' => nil}})
      assert_nil saved_host.test_facet

      saved_host.update({'test_facet_attributes' => { 'my_attribute' => "val"}})
      assert_not_nil saved_host.test_facet
    end

    test 'facet is not removed when associated host is deleted' do
      as_admin do
        saved_host = FactoryBot.create(:host)
        facet = saved_host.build_test_facet
        saved_host.save!
        assert facet.id
        saved_host.destroy!
        assert TestFacet.find_by(id: facet.id)
      end
    end
  end

  context 'managed host facet dependent destroy behavior' do
    setup do
      Facets.register TestFacet do
        set_dependent_action :destroy
      end
    end

    test 'facet is removed when associated host is deleted' do
      as_admin do
        saved_host = FactoryBot.create(:host)
        facet = saved_host.build_test_facet
        saved_host.save!
        assert facet.id
        saved_host.destroy!
        refute TestFacet.find_by(id: facet.id)
      end
    end
  end

  context 'inside db:migrate task' do
    setup do
      Foreman.stubs(:in_setup_db_rake?).returns(true)
    end

    test 'facet can be registered more than once' do
      # register facet twice
      Facets.register TestFacet
      Facets.register TestFacet

      @host = Host::Managed.new

      @host.test_facet
    end
  end

  context 'hostgroup facet behavior' do
    test 'inherited attributes are defined by inherit_attributes class method' do
      TestHostgroupFacet.stubs(:attributes_to_inherit).returns([])
      TestHostgroupFacet.inherit_attributes :to_inherit

      facet = TestHostgroupFacet.new
      facet.stubs(:attributes).returns({:to_inherit => 'val1', :dont_inherit => 'val2'})

      actual = facet.inherited_attributes

      assert_equal({:to_inherit => 'val1'}, actual)
    end

    test 'all attributes are inherited for same facet in host and hostgroup' do
      Facets.register :same_facet do
        configure_hostgroup TestHostAndHostrgoupFacet
        configure_host TestHostAndHostrgoupFacet
      end

      TestHostAndHostrgoupFacet.expects(:attribute_names).returns(['id', 'created_at', 'updated_at', 'attr1', 'attr2'])

      actual = TestHostAndHostrgoupFacet.attributes_to_inherit

      assert_equal(['attr1', 'attr2'], actual)
    end
  end

  context 'hostgroup behavior' do
    setup do
      Facets.register :hostgroup_facet do
        configure_hostgroup TestHostgroupFacet
        configure_host TestFacet
      end

      @hostgroup = Hostgroup.new
      @facet = @hostgroup.build_hostgroup_facet
    end

    test 'attributes inherited by default' do
      grand_parent = Hostgroup.new
      grand_parent_facet = grand_parent.build_hostgroup_facet
      parent = Hostgroup.new
      parent_facet = parent.build_hostgroup_facet
      grand_parent_facet.expects(:inherited_attributes).returns(grand_only: 'grand', parent: 'grand', local: 'grand')
      parent_facet.expects(:inherited_attributes).returns(grand_only: nil, parent: 'parent', local: 'parent')
      @facet.expects(:inherited_attributes).returns(grand_only: nil, parent: nil, local: 'local')

      @hostgroup.expects(:hostgroup_ancestry_cache).returns([grand_parent, parent])
      actual = @hostgroup.inherited_facet_attributes(Facets.registered_facets[:hostgroup_facet])

      assert_equal({grand_only: 'grand', parent: 'parent', local: 'local'}, actual)
    end

    test 'attributes inherited from leaf without facet' do
      parent = Hostgroup.new
      parent_facet = parent.build_hostgroup_facet
      parent_facet.expects(:inherited_attributes).returns(parent: 'parent', local: 'parent')
      @facet.expects(:inherited_attributes).returns(parent: nil, local: 'local')

      # Hostgroup without facet attached
      child = Hostgroup.new

      child.expects(:hostgroup_ancestry_cache).returns([parent, @hostgroup])
      actual = child.inherited_facet_attributes(Facets.registered_facets[:hostgroup_facet])

      assert_equal({parent: 'parent', local: 'local'}, actual)
    end

    test 'hostgroup and facet are connected two-way' do
      assert_equal @hostgroup, @facet.hostgroup
    end
  end

  context 'host and hostgroup relationship' do
    test 'host facet is getting attributes from hostgroup facet' do
      Facets.register :hostgroup_facet do
        configure_host TestFacet
        configure_hostgroup TestHostgroupFacet
      end

      host = Host::Managed.new
      hostgroup = FactoryBot.create(:hostgroup, :hostgroup_facet => TestHostgroupFacet.new)

      TestHostgroupFacet.stubs(:attributes_to_inherit).returns([])
      TestHostgroupFacet.inherit_attributes :to_inherit
      TestHostgroupFacet.any_instance.stubs(:attributes).returns({:to_inherit => 'val1', :dont_inherit => 'val2'})

      actual = host.apply_inherited_attributes('hostgroup' => hostgroup)

      assert_equal({'to_inherit' => 'val1'}, actual['hostgroup_facet_attributes'])
    end
  end
end
