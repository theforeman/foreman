# various methods which gets included in the dashboard and hosts controller
module Foreman::Controller::FactSelection
  # host list AJAX methods
  # its located here, as it might be requested from the dashboard controller or via the hosts controller
  def fact_selected
    @fact_name_id = params[:search_fact_name_id].to_i
    @via    = params[:via]
    @values = FactValue.fact_name_id_eq(@fact_name_id).ascend_by_value.all(:select => "DISTINCT value") if @fact_name_id > 0

    render :partial => 'common/fact_selected', :layout => false
  end
end
