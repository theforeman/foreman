if RUBY_VERSION >= "1.9.3"
  require 'rubocop/rake_task'

  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop)
end