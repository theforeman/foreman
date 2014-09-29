require "fast_gettext"
require "gettext_i18n_rails"
require "gettext_i18n_rails/tasks"
require "gettext_i18n_rails_js/tasks"
require File.expand_path("../../../lib/foreman/gettext/support.rb", __FILE__)

namespace :gettext do

  # redefine locale path to be taken from current directory (for plugins)
  def locale_path
    path = FastGettext.translation_repositories[text_domain].instance_variable_get(:@options)[:path] rescue nil
    path || "locale"
  end

  # redefine file globs for Foreman
  def files_to_translate
    Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,haml,slim,rhtml,js,rabl}")
  end
end

desc 'Extract plugin strings - called via rake plugin:gettext[plugin_name]'
task 'plugin:gettext', :engine do |t, args|

  @engine = "#{args[:engine].camelize}::Engine".constantize
  @engine_root = @engine.root

  namespace :gettext do

    def locale_path
      "#{@engine_root}/locale"
    end

    def files_to_translate
      Dir.glob("#{@engine.root}/{app,db,lib,config,locale}/**/*.{rb,erb,haml,slim,rhtml,js}")
    end

  end

  Foreman::Gettext::Support.add_text_domain args[:engine], "#{@engine_root}/locale"
  ENV['TEXTDOMAIN'] = args[:engine]

  Rake::Task['gettext:find'].invoke

end
