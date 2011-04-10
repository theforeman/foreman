module Foreman::Controller::AutoCompleteSearch
  def auto_complete_search
    begin
      @items = eval(controller_name.singularize.camelize).complete_for(params[:search])
      @items = @items.map do |item|
        category = (['and','or','not','has'].include?(item.to_s.sub(/^.*\s+/,''))) ? 'Operators' : ''
        {:label => item, :category => category}
      end
    rescue ScopedSearch::QueryNotSupported => e
      @items = e.to_s
    end
    render :json => @items
  end

end
