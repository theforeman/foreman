require 'minitest/autorun'
require 'json'
require 'open3'
require 'tmpdir'
require 'rbconfig'

class PostgreSQLDumpWrapperTest < Minitest::Test
  WRAPPER = File.expand_path('postgresql/pg_dump', __dir__)

  def setup
    @directory = Dir.mktmpdir('foreman-pg-dump-test-')
    docker = File.join(@directory, 'docker')
    File.write(docker, <<~RUBY)
      #!#{RbConfig.ruby}
      require 'json'
      puts JSON.generate(ARGV)
      exit Integer(ENV.fetch('PG_DUMP_TEST_STATUS', '0'))
    RUBY
    File.chmod(0o755, docker)
    @environment = {
      'PATH' => "#{@directory}:#{ENV.fetch('PATH')}",
      'GITHUB_WORKSPACE' => '/tmp/checkout with spaces',
      'FOREMAN_POSTGRES_IMAGE' => 'postgres:13',
      'PGPASSWORD' => 'test password must not appear in arguments',
    }
  end

  def teardown
    File.unlink(File.join(@directory, 'docker'))
    Dir.rmdir(@directory)
  end

  def test_preserves_dump_arguments_and_uses_the_matching_client_image
    arguments = ['--schema-only', '--file', '/tmp/checkout with spaces/db/structure.sql', 'test']
    stdout, stderr, status = Open3.capture3(@environment, WRAPPER, *arguments)

    assert status.success?, stderr
    command = JSON.parse(stdout)
    assert_equal ['postgres:13', 'pg_dump', *arguments], command.last(arguments.length + 2)
    assert_includes command, '--pull=never'
    assert_includes command, '--network=host'
    assert_includes command, '/tmp/checkout with spaces:/tmp/checkout with spaces'
    assert_includes command, Dir.pwd
    assert_includes command, "#{Process.uid}:#{Process.gid}"
    assert_includes command, 'PGPASSWORD'
    refute_includes command, @environment['PGPASSWORD']
  end

  def test_propagates_the_dump_exit_status
    stdout, stderr, status = Open3.capture3(@environment.merge('PG_DUMP_TEST_STATUS' => '17'), WRAPPER, '--version')

    assert_equal 17, status.exitstatus, "#{stdout}\n#{stderr}"
  end

  def test_requires_an_explicit_service_image
    stdout, stderr, status = Open3.capture3(@environment.merge('FOREMAN_POSTGRES_IMAGE' => nil), WRAPPER, '--version')

    refute status.success?
    assert_empty stdout
    assert_includes stderr, 'FOREMAN_POSTGRES_IMAGE'
  end
end
