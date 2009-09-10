class MediasController < ApplicationController
  active_scaffold :media do |config|
    config.columns = [:name, :path, :operatingsystem ]
    config.label = "Installation medias"
    config.columns[:name].description = "Media's name, for example CentOS 5 mirror"
    config.columns[:path].description = "the path to the media, can be a url or an NFS server, must not include the archetecture, for example http://mirror.averse.net/centos/5.3/os/$arch where <b>$arch</b> will be subsituded for the host actual OS"
    config.columns[:operatingsystem].form_ui  = :select
    config.columns[:operatingsystem].label = "Operating system"
  end
end
