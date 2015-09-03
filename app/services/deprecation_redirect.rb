class DeprecationRedirect
  def initialize(redirect, params = nil, query_string, version, message)
    Foreman::Deprecation.deprecation_warning(version, message)
    @redirect = redirect
    @params = params
    @query_string = query_string
  end

  def redirect_url
    return "/#{@redirect}/#{@params[:id]}?#{@query_string}" if @params && @params[:id]
    "/#{@redirect}?#{@query_string}"
  end
end
