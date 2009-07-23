class OperatingsystemController < ApplicationController
  active_scaffold :operatingsystem do |config|
    config.columns = [:name, :major, :architectures, :medias, :minor, :nameindicator, :hosttypes]
    config.columns[:architectures].form_ui  = :select
    config.columns[:hosttypes].form_ui  = :select
    config.columns[:medias].form_ui  = :select
  end
end
