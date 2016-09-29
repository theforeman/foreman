begin
  require 'rubocop/rake_task'

  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
  # rubocop unavailable
end
