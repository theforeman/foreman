require 'test_helper'

class Queries::AuthorizedModelQueryTest < GraphQLQueryTestCase
  describe '#results' do
    test 'does not return records for missing user' do
      as_admin { FactoryBot.create(:host) }

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: nil)
                                            .results

      assert_empty result
    end

    test 'does not return records for not authorized user' do
      user = as_admin { FactoryBot.create(:user) }
      as_admin { FactoryBot.create(:host) }

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: user)
                                            .results

      assert_empty result
    end

    test 'returns records for authorized user' do
      user = as_admin { setup_user 'view', 'hosts' }
      host = as_admin { FactoryBot.create(:host) }

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: user)
                                            .results

      assert_equal [host], result
    end

    test 'searches results when search param present' do
      user = as_admin { setup_user 'view', 'hosts' }
      excluded_host = as_admin { FactoryBot.create(:host) }
      included_host = as_admin { FactoryBot.create(:host, hostname: 'sample host 1') }

      result = Queries::AuthorizedModelQuery.new(
        model_class: Host::Managed, user: user
      ).results(search: 'name ~ "sample"')

      refute_includes result, excluded_host
      assert_equal [included_host], result
    end

    test 'searches and order results when search param present' do
      user = as_admin { setup_user 'view', 'hosts' }
      excluded_host = as_admin { FactoryBot.create(:host) }
      included_hosts = as_admin do
        [
          FactoryBot.create(:host, hostname: 'sample host 1'),
          FactoryBot.create(:host, hostname: 'a sample host 1')
        ]
      end

      result = Queries::AuthorizedModelQuery.new(
        model_class: Host::Managed, user: user
      ).results(search: 'name ~ "sample"', order_by: 'name', order: 'DESC')

      refute_includes result, excluded_host
      assert_equal included_hosts, result
    end

    test 'returns ordered records for authorized user by given order_by' do
      user = as_admin { setup_user 'view', 'hosts' }
      old_host = as_admin { FactoryBot.create(:host, created_at: Time.zone.now - 2.days) }
      new_host = as_admin { FactoryBot.create(:host, created_at: Time.zone.now) }

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: user)
                                            .results(order_by: 'created_at')

      assert_equal [old_host, new_host], result
    end

    test 'returns ordered records for authorized user by given order_by and order' do
      user = as_admin { setup_user 'view', 'hosts' }
      old_host = as_admin { FactoryBot.create(:host, created_at: Time.zone.now - 2.days) }
      new_host = as_admin { FactoryBot.create(:host, created_at: Time.zone.now) }

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: user)
                                            .results(order_by: 'created_at', order: 'desc')

      assert_equal [new_host, old_host], result
    end
  end
end
