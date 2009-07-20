class MediaController < ApplicationController
  active_scaffold :media do |config|
    config.columns = [:name, :path, :operatingsystem ]
  end
end
