require 'minitest/autorun'
require 'json'

class PluginWebpackDirectoriesTest < Minitest::Test
  def setup
    @root_dir = File.expand_path(File.join(%w[.. .. .. ..]), __FILE__)
    @script = File.join(%W[#{@root_dir} script plugin_webpack_directories.rb])
  end

  def test_bundler
    plugin_webpack = `#{@script}`

    assert File.exist?(@script)
    assert_equal JSON.parse(plugin_webpack).keys(), ['entries', 'paths']
  end
end
