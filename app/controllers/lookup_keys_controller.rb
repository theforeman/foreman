class LookupKeysController < ApplicationController
  before_filter :require_login, :except => :q
  before_filter :require_ssl, :except => :q

  def index
    @lookup_key = LookupKey.all
  end

  def show
    @lookup_key = LookupKey.find(params[:id])
  end

  def new
    @lookup_key = LookupKey.new
    2.times { @lookup_key.lookup_values.build }
  end

  def edit
    @lookup_key = LookupKey.find(params[:id])
  end

  def create
    @lookup_key = LookupKey.new(params[:lookup_key])

    if @lookup_key.save
      flash[:foreman_notice] = 'Successfully created.'
      redirect_to (lookup_keys_url)
    else
      render :action => "new"
    end
  end

  def update
    @lookup_key = LookupKey.find(params[:id])

    if @lookup_key.update_attributes(params[:lookup_key])
      flash[:foreman_notice] = 'Successfully updated.'
      redirect_to(lookup_keys_url)
    else
      render :action => "edit"
    end
  end

  def destroy
    @lookup_key = LookupKey.find(params[:id])
    @lookup_key.destroy

    redirect_to(lookup_keys_url)
  end

  # query action providing variable names - e.g. for extlookup
  def q
    key, order = params[:key], params[:order]
    invalid_request if key.nil? or order.nil? or not order.is_a?(Array)
    output = LookupKey.search(key, order)
    render :text => '404 Not Found', :status => 404 and return unless output
    respond_to do |format|
        format.html { render :text => output }
        format.yml { render :text => output.to_yaml }
    end
  end

end
