require 'test_helper'

class WikiTest < ActiveSupport::TestCase
  setup do
    @data = {
      "core" => {
        "1" => {
          "10" => ["1.10.2", "1.10.1"],
          "9"  => ["1.9.3", "1.9.0-RC1"]
        },
        "0" => {
          "0" => ["0.0.1"]
        }
      },
      "plugins" => {
        "foreman-tasks" => {
          "0.7.15" => {
            "requires_foreman" => "1.9"
          },
          "0.7.1" => {
            "requires_foreman" => "1.6"
          }
        },
        "foreman_docker" => {
          "2.0.1" => {
            "requires_foreman" => "1.11"
          },
          "1.8.6" => {
            "requires_foreman" => "1.9"
          }
        }
      }
    }
    @wiki = Updates::Wiki.new
  end

  test 'should get latest plugin versions' do
    Foreman::Plugin.stubs(:all).returns(setup_plugins)
    SETTINGS[:version] = Foreman::Version.new "1.9.3"
    assert_equal [{"foreman-tasks" => "0.7.15"}, {"foreman_docker" => "1.8.6"}], @wiki.latest_plugin_version_for_current_foreman(@data)
  end

  test 'should get latest core version' do
    SETTINGS[:version] = Foreman::Version.new "1.9.1"
    assert_equal({ :latest => "1.10.2", :current_latest => "1.9.3" }, @wiki.latest_core_version_for_current_foreman(@data))
  end

  private

  def setup_plugins
    ["foreman-tasks", "foreman_docker"].map do |item|
      p = Foreman::Plugin.send :new, item
      p.foreman_req = ">= 1.9"
      p
    end
  end
end
