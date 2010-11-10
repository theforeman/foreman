module Facts
  # the methods below are shared between multiple controllers (like the search bar in the host and facts pages)

 def fact_selected
    @fact_name_id = params[:search_fact_name_id].to_i
    @via    = params[:via]
    @values = FactValue.fact_name_id_eq(@fact_name_id).ascend_by_value.all(:select => "DISTINCT value") if @fact_name_id > 0

    render :partial => 'common/fact_selected', :layout => false
  end

end
