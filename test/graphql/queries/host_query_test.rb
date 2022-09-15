require 'test_helper'

module Queries
  class HostQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
    query (
        $id: String!
      ) {
        host(id: $id) {
          id
          createdAt
          updatedAt
          name
          build
          managed
          ip
          ip6
          path
          mac
          lastReport
          domainName
          pxeLoader
          enabled
          uuid
          computeResource {
            id
          }
          computeProfile {
            id
          }
          architecture {
            id
          }
          ptable {
            id
          }
          domain {
            id
          }
          location {
            id
          }
          organization {
            id
          }
          model {
            id
          }
          operatingsystem {
            id
          }
          puppetCaProxy {
            id
          }
          medium {
            id
          }
          hostgroup {
            id
          }
          subnet {
            id
          }
          owner {
            ... on User {
              id
              login
            }
          }
          factNames {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          factValues {
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

    let(:host) do
      as_admin do
        hostgroup = FactoryBot.create(:hostgroup, :with_compute_resource)
        owner = FactoryBot.create(:user)
        FactoryBot.create(:host, :managed,
          :dualstack,
          :with_model,
          :with_facts,
          :with_puppet_ca,
          :on_compute_resource,
          :with_compute_profile,
          hostgroup: hostgroup,
          uuid: Foreman.uuid,
          owner: owner,
          last_report: Time.now)
      end
    end
    let(:global_id) { Foreman::GlobalId.encode('Host', host.id) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['host'] }

    test 'fetching host attributes' do
      assert_empty result['errors']
      assert_equal global_id, data['id']
      assert_equal host.created_at.utc.iso8601, data['createdAt']
      assert_equal host.updated_at.utc.iso8601, data['updatedAt']
      assert_equal host.name, data['name']
      assert_equal host.build, data['build']
      assert_equal host.managed, data['managed']
      assert_equal host.ip, data['ip']
      assert_equal host.ip6, data['ip6']
      assert_equal Rails.application.routes.url_helpers.host_path(host), data['path']
      assert_equal host.mac, data['mac']
      assert_equal host.last_report.utc.iso8601, data['lastReport']
      assert_equal host.domain_name, data['domainName']
      assert_equal host.pxe_loader, data['pxeLoader']
      assert_equal host.enabled, data['enabled']
      assert_equal host.uuid, data['uuid']

      assert_record host.compute_resource, data['computeResource'], type_name: 'ComputeResource'
      assert_record host.architecture, data['architecture']
      assert_record host.ptable, data['ptable']
      assert_record host.domain, data['domain']
      assert_record host.location, data['location']
      assert_record host.model, data['model']
      assert_record host.organization, data['organization']
      assert_record host.operatingsystem, data['operatingsystem']
      assert_record host.puppet_ca_proxy, data['puppetCaProxy']
      assert_record host.medium, data['medium']
      assert_record host.hostgroup, data['hostgroup']
      assert_record host.subnet, data['subnet'], type_name: 'Subnet'
      assert_record host.owner, data['owner']
      assert_record host.compute_profile, data['computeProfile']

      assert_equal host.owner.login, data['owner']['login']

      assert_collection host.fact_names, data['factNames']
      assert_collection host.fact_values, data['factValues']
    end

    context 'with user without view_models permission' do
      let(:context_user) { setup_user 'view', 'hosts' }

      test 'does not load associated model' do
        assert_empty result['errors']

        assert_nil data['model']
      end
    end

    context 'with user without view_hosts permission' do
      let(:context_user) { setup_user 'view', 'models' }

      test 'does not load any hosts' do
        assert_empty result['errors']

        assert_nil data
      end
    end
  end
end
