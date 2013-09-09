require "fast_gettext"
require "gettext_i18n_rails"
require "gettext_i18n_rails/tasks"
require "gettext_i18n_rails_js/tasks"

namespace :gettext do

  # redefine locale path to be taken from current directory (for plugins)
  def locale_path
    "locale"
  end

  # redefine file globs for Foreman
  def files_to_translate
    Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,haml,slim,rhtml,js}")
  end
end
