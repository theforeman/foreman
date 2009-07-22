class MediaController < ApplicationController
  active_scaffold :medias do |config|
    config.columns = [:name, :path, :operatingsystem ]
  end
end
