class OperatingsystemController < ApplicationController
  active_scaffold :operatingsystem do |config|
    config.columns = [:name, :major, :architectures, :medias, :minor, :nameindicator]
    config.columns[:architectures].form_ui  = :select
  end
end
