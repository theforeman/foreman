module Foreman::Controller::AutoCompleteSearch
  extend ActiveSupport::Concern

  included do
    before_action :reset_redirect_to_url, :only => [:index, :show]
    before_action :store_redirect_to_url, :except => [:index, :show, :create, :update]
  end

  def auto_complete_search
    begin
      model = (controller_name == "hosts") ? Host::Managed : model_of_controller
      @items = model.complete_for(params[:search], {:controller => controller_name})
      @items = @items.map do |item|
        category = ['and', 'or', 'not', 'has'].include?(item.to_s.sub(/^.*\s+/, '')) ? _('Operators') : ''
        part = item.to_s.sub(/^.*\b(and|or)\b/i) { |match| match.sub(/^.*\s+/, '') }
        completed = item.to_s.chomp(part)
        {:completed => CGI.escapeHTML(completed), :part => CGI.escapeHTML(part), :label => item, :category => category}
      end
    rescue ScopedSearch::QueryNotSupported => e
      @items = [{:error => e.to_s}]
    end
    render :json => @items
  end

  def invalid_search_query(e)
    error (_("Invalid search query: %s") % e)
    redirect_back(fallback_location: public_send("#{controller_name}_path"))
  end

  def reset_redirect_to_url
    session["redirect_to_url_#{controller_name}"] = nil
  end

  def store_redirect_to_url
    session["redirect_to_url_#{controller_name}"] ||= request.referer
  end
end
