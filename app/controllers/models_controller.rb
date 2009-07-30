class ModelsController < ApplicationController
  active_scaffold :model do |config|
    config.columns = [ :name, :info ]
    config.columns[:info].description = "general useful text, for example this kind of hardware needs a special bios setup"
  end

end
