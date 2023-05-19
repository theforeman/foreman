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

  desc 'Extract plugin strings - called via rake plugin:gettext[engine]'
  task 'plugin:gettext', [:engine] => [:environment] do |t, args|
    unless args[:engine]
      puts "You must specify the name of the plugin (e.g. rake plugin:gettext['my_plugin'])"
      exit 1
    end

    @plugin = Foreman::Plugin.find(args[:engine]) or raise("Unable to find registered plugin #{args[:engine]}")
    @engine = @plugin.engine
    @domain = @plugin.gettext_domain

    raise "Plugin '#{@plugin.name}' does not have translations registered'" unless @domain

    namespace :gettext do
      def locale_path
        @plugin.locale_path
      end

      def files_to_translate
        @engine.root.glob(FILE_GLOB).map(&:to_s)
      end

      def text_domain
        @domain
      end
    end

    Foreman::Gettext::Support.add_text_domain @domain, @plugin.locale_path

    Rake::Task['gettext:find'].invoke
  end

  desc 'Convert plugin strings to json - called via rake plugin:po_to_json[plugin_name]'
  task 'plugin:po_to_json', [:engine] => [:environment] do |t, args|
    unless args[:engine]
      puts "You must specify the name of the plugin (e.g. rake plugin:po_to_json['my_plugin'])"
      exit 1
    end

    plugin = Foreman::Plugin.find(args[:engine]) or raise("Unable to find registered plugin #{args[:engine]}")
    engine = plugin.engine
    domain = plugin.gettext_domain

    raise "Plugin '#{plugin.name}' does not have translations registered'" unless domain

    module GettextI18nRailsJs::Task
      def locale_path
        @locale_path
      end
    end

    GettextI18nRailsJs.config.jed_options = {
      pretty: true,
      domain: domain,
      variable: "locales['#{domain}']",
      variable_locale_scope: false,
    }
    GettextI18nRailsJs.config.output_path = File.join('app', 'assets', 'javascripts', plugin.name, 'locale')
    GettextI18nRailsJs.config.domain = domain
    GettextI18nRailsJs.config.rails_engine = engine

    GettextI18nRailsJs::Task.instance_variable_set(:@locale_path, engine.root)
    GettextI18nRailsJs::Task.po_to_json
  end
rescue LoadError
  # gettext unavailable
  # this can happen as gettext is a development-only dependency used in
  # gettext_i18n_rails*/tasks for extraction, but not generally runtime
end
