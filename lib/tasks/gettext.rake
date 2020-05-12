begin
  require "fast_gettext"
  require "gettext_i18n_rails"
  require "gettext_i18n_rails/tasks"
  require "gettext_i18n_rails_js/task"
  require File.expand_path('../../lib/foreman/gettext/support.rb', __dir__)

  FILE_GLOB = '{app,db/seeds.d,lib,config,locale,webpack}/**/*.{rb,erb,haml,slim,rhtml,js,rabl}'

  namespace :gettext do
    # redefine locale path to be taken from current directory (for plugins)
    def locale_path
      path = FastGettext.translation_repositories[text_domain].instance_variable_get(:@options)[:path] rescue nil
      path || "locale"
    end

    # redefine file globs for Foreman
    def files_to_translate
      Dir.glob(FILE_GLOB)
    end
  end

  desc 'Extract plugin strings - called via rake plugin:gettext[plugin_name]'
  task 'plugin:gettext', :engine do |t, args|
    @domain = args[:engine]
    @engine = "#{@domain.camelize}::Engine".constantize
    @engine_root = @engine.root

    namespace :gettext do
      def locale_path
        "#{@engine_root}/locale"
      end

      def files_to_translate
        Dir.glob(File.join(@engine.root, FILE_GLOB))
      end

      def text_domain
        @domain
      end
    end

    Foreman::Gettext::Support.add_text_domain @domain, "#{@engine_root}/locale"

    Rake::Task['gettext:find'].invoke
  end
rescue LoadError
  # gettext unavailable
  # this can happen as gettext is a development-only dependency used in
  # gettext_i18n_rails*/tasks for extraction, but not generally runtime
end
