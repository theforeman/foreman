require 'test_helper'

module Queries
  class HostgroupQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        hostgroup(id: $id) {
          id
          createdAt
          updatedAt
          name
          title
          environment {
            id
          }
          computeResource {
            id
          }
          architecture {
            id
          }
          domain {
            id
          }
          operatingsystem {
            id
          }
          puppetCaProxy {
            id
          }
          puppetProxy {
            id
          }
          ptable {
            id
          }
          medium {
            id
          }
          hosts {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          puppetclasses {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          locations {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          organizations {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          parent {
            id
          }
          children {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          descendants {
            totalCount
            edges {
              node {
                id
              }
            }
          }
        }
      }
      GRAPHQL
    end

    let(:parent_hostgroup) { FactoryBot.create(:hostgroup) }
    let(:medium) { FactoryBot.create(:medium) }
    let(:operatingsystem) { FactoryBot.create(:operatingsystem, family: 'Redhat', media: [medium]) }
    let(:hostgroup) do
      FactoryBot.create(
        :hostgroup,
        :with_compute_resource,
        :with_environment,
        :with_puppetclass,
        :with_subnet,
        :with_os,
        :with_domain,
        :with_puppet_orchestration,
        parent: parent_hostgroup,
        operatingsystem: operatingsystem
      )
    end
    let(:child_hostgroup) { FactoryBot.create(:hostgroup, parent: hostgroup) }
    let(:second_child_hostgroup) { FactoryBot.create(:hostgroup, :parent => hostgroup) }
    let(:grandchild_hostgroup) { FactoryBot.create(:hostgroup, :parent => child_hostgroup) }

    let(:global_id) { Foreman::GlobalId.for(hostgroup) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['hostgroup'] }

    setup do
      child_hostgroup
      second_child_hostgroup
      grandchild_hostgroup
      FactoryBot.create(:host, hostgroup: hostgroup)
    end

    test 'fetching hostgroup attributes' do
      assert_empty result['errors']
      assert_equal global_id, data['id']
      assert_equal hostgroup.created_at.utc.iso8601, data['createdAt']
      assert_equal hostgroup.updated_at.utc.iso8601, data['updatedAt']
      assert_equal hostgroup.name, data['name']
      assert_equal hostgroup.title, data['title']

      assert_record hostgroup.environment, data['environment']
      assert_record hostgroup.compute_resource, data['computeResource'], type_name: 'ComputeResource'
      assert_record hostgroup.architecture, data['architecture']
      assert_record hostgroup.domain, data['domain']
      assert_record hostgroup.operatingsystem, data['operatingsystem'], type_name: 'Operatingsystem'
      assert_record hostgroup.puppet_ca_proxy, data['puppetCaProxy']
      assert_record hostgroup.puppet_proxy, data['puppetProxy']
      assert_record hostgroup.ptable, data['ptable']
      assert_record hostgroup.medium, data['medium']

      assert_collection hostgroup.hosts, data['hosts'], type_name: 'Host'
      assert_collection hostgroup.puppetclasses, data['puppetclasses']
      assert_collection hostgroup.locations, data['locations']
      assert_collection hostgroup.organizations, data['organizations']

      assert_record hostgroup.parent, data['parent']
      assert_collection hostgroup.children, data['children']
      assert_collection hostgroup.descendants, data['descendants']
    end
  end
end
