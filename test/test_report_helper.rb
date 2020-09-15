require 'minitest/reporters'

junit_reporter = Minitest::Reporters::JUnitReporter.new('jenkins/reports/unit/')
meantime_reporter = Minitest::Reporters::MeanTimeReporter.new(previous_runs_filename: Rails.root.join('tmp', 'foreman_minitest_reporters_previous_run'),
                                                              report_filename: Rails.root.join('tmp', 'foreman_minitest_reporters_report'))

Minitest::Reporters.use! [junit_reporter, meantime_reporter]
