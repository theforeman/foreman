class MediasController < ApplicationController
  active_scaffold :media do |config|
    config.columns = [:name, :path, :operatingsystem ]
    config.columns[:name].description = "Media's name, for example CentOS 5 mirror"
    config.columns[:path].description = "the path to the media, can be a url or an NFS server, must not include the archetecture, for example http://mirror.averse.net/centos/5.3/os/"
    config.columns[:operatingsystem].form_ui  = :select
  end
end
