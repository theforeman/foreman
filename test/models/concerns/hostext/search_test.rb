require 'test_helper'

module Hostext
  class SearchTest < ActiveSupport::TestCase
    context 'host exists' do
      setup do
        @host = FactoryBot.create(:host)
      end

      test "can be found by config group" do
        config_group = FactoryBot.create(:config_group)
        @host.config_groups = [ config_group ]
        result = Host.search_for("config_group = #{config_group.name}")
        assert_includes result, @host
      end

      test "search by config group returns only host within that config group" do
        config_group = FactoryBot.create(:config_group)
        result = Host.search_for("config_group = #{config_group.name}")
        assert_not_includes result, @host
      end
    end
  end
end
