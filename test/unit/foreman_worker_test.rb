require 'test_helper'
require 'open3'
require 'tmpdir'

class ForemanWorkerTest < ActiveSupport::TestCase
  SCRIPT = Rails.root.join('script/foreman-worker').to_s
  SERVICE = Rails.root.join('extras/systemd/dynflow-sidekiq@.service').to_s

  test 'systemd service uses the packaged worker entry point' do
    assert_includes File.read(SERVICE), 'ExecStart=/usr/libexec/foreman/foreman-worker %i'
  end

  test 'starts the requested worker with the expected configuration' do
    output, status = run_worker('worker-hosts-queue', 'RAILS_ENV' => nil)

    assert status.success?, output
    assert_equal <<~OUTPUT, output
      -e
      production
      -r
      /usr/share/foreman/extras/dynflow-sidekiq.rb
      -C
      /etc/foreman/dynflow/worker-hosts-queue.yml
    OUTPUT
  end

  test 'passes through the configured Rails environment' do
    output, status = run_worker('worker', 'RAILS_ENV' => 'development')

    assert status.success?, output
    assert_includes output, "-e\ndevelopment\n"
  end

  test 'rejects an unsafe worker instance' do
    output, status = Open3.capture2e(SCRIPT, '../worker')

    assert_equal 64, status.exitstatus
    assert_equal "Invalid worker instance: ../worker\n", output
  end

  test 'requires exactly one worker instance' do
    output, status = Open3.capture2e(SCRIPT)

    assert_equal 64, status.exitstatus
    assert_match(/Usage: .*foreman-worker INSTANCE/, output)
  end

  private

  def run_worker(instance, environment = {})
    Dir.mktmpdir do |directory|
      sidekiq = File.join(directory, 'sidekiq')
      File.write(sidekiq, "#!/bin/sh\nprintf '%s\\n' \"\$@\"\n")
      File.chmod(0o755, sidekiq)

      path = [directory, ENV.fetch('PATH')].join(File::PATH_SEPARATOR)
      Open3.capture2e({'PATH' => path}.merge(environment), SCRIPT, instance)
    end
  end
end
