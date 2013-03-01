require "fast_gettext"
require "gettext_i18n_rails"
require "gettext_i18n_rails/tasks"

namespace :gettext do
  def files_to_translate
    Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,haml,slim,rhtml}")
  end
end
