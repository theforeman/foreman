# the jshint options was set to "sane defaults" because jshint is very strict
namespace :test do

  if Rails.env.development? or Rails.env.test?
    begin
      require "jshintrb/jshinttask"

      Jshintrb::JshintTask.new :jshint do |t|
        t.pattern         = ['app/assets/javascripts/**/*.js',
                             'vendor/assets/javascripts/**/*.js']
        t.exclude_pattern = 'vendor/assets/javascripts/**/*.js'
        t.options         = {
          # relaxing options
          :asi       => true,
          :eqnull    => true,
          :loopfunc  => true,
          # enforcing options
          :bitwise   => true,
          :curly     => false,
          :eqeqeq    => false,
          :forin     => true,
          :immed     => true,
          :latedef   => false,
          :newcap    => false,
          :noarg     => true,
          :noempty   => true,
          :nonew     => true,
          :plusplus  => false,
          :regexp    => true,
          :undef     => false,
          :strict    => false,
          :trailing  => true,
          :browser   => true,
          :jquery    => true,
          :passfail  => false,
          :white     => false,
          :sub       => true,
          :lastsemic => true,
          :smarttabs => true
        }
      end
    rescue LoadError
      warn "install jshintrb gem"
    end
  end

end

Rake::Task[:test].enhance do
  Rake::Task['test:jshint'].invoke
end
