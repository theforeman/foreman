require 'minitest/reporters'

if ENV['GITHUB_ACTIONS'] == 'true'
  require 'minitest_reporters_github'
  reporters = [MinitestReportersGithub.new]
else
  reporters = [
    Minitest::Reporters::JUnitReporter.new('jenkins/reports/unit/'),
    Minitest::Reporters::MeanTimeReporter.new(
      previous_runs_filename: Rails.root.join('tmp', 'foreman_minitest_reporters_previous_run'),
      report_filename: Rails.root.join('tmp', 'foreman_minitest_reporters_report')
    ),
  ]
end

Minitest::Reporters.use! reporters
