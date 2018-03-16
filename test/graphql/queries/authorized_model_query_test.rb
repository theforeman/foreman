require 'test_helper'

class Queries::AuthorizedModelQueryTest < ActiveSupport::TestCase
  describe '#find_by' do
    test 'does not return record for missing user' do
      host = FactoryBot.create(:host)

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: nil)
                                            .find_by(id: host.id)

      assert_nil result
    end

    test 'does not return record for not authorized user' do
      user = FactoryBot.create(:user)
      host = FactoryBot.create(:host)

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: user)
                                            .find_by(id: host.id)

      assert_nil result
    end

    test 'returns record for authorized user' do
      user = setup_user 'view', 'hosts'
      host = FactoryBot.create(:host)

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: user)
                                            .find_by(id: host.id)

      assert_equal result, host
    end
  end

  describe '#results' do
    test 'does not return records for missing user' do
      FactoryBot.create(:host)

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: nil)
                                            .results

      assert_empty result
    end

    test 'does not return records for not authorized user' do
      user = FactoryBot.create(:user)
      FactoryBot.create(:host)

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: user)
                                            .results

      assert_empty result
    end

    test 'returns records for authorized user' do
      user = setup_user 'view', 'hosts'
      host = FactoryBot.create(:host)

      result = Queries::AuthorizedModelQuery.new(model_class: Host::Managed, user: user)
                                            .results

      assert_equal result, [host]
    end

    test 'searches and order results when search param present' do
      user = setup_user 'view', 'hosts'
      excluded_host = FactoryBot.create(:host)
      included_hosts = [
        FactoryBot.create(:host, hostname: 'sample host 1'),
        FactoryBot.create(:host, hostname: 'a sample host 1')
      ]

      result = Queries::AuthorizedModelQuery.new(
        model_class: Host::Managed, user: user
      ).results(search: 'name ~ "sample"', order: 'name DESC')

      refute_includes result, excluded_host
      assert_equal result, included_hosts
    end
  end
end
