class PuppetclassesController < ApplicationController
  def index
    @puppetclasses = Puppetclass.all.paginate :page => params[:page], :limit => 15
  end

  def new
    @puppetclass = Puppetclass.new
  end

  def create
    @puppetclass = Puppetclass.new(params[:puppetclass])
    if @puppetclass.save
      flash[:foreman_notice] = "Successfully created puppetclass."
      redirect_to puppetclasses_url
    else
      render :action => 'new'
    end
  end

  def edit
    @puppetclass = Puppetclass.find(params[:id])
  end

  def update
    @puppetclass = Puppetclass.find(params[:id])
    if @puppetclass.update_attributes(params[:puppetclass])
      flash[:foreman_notice] = "Successfully updated puppetclass."
      redirect_to puppetclasses_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @puppetclass = Puppetclass.find(params[:id])
    if @puppetclass.destroy
      flash[:foreman_notice] = "Successfully destroyed puppetclass."
    else
      flash[:foreman_error] = @puppetclass.errors.full_messages.join("<br>")
    end
    redirect_to puppetclasses_url
  end

  def import
    ec, pc = Environment.count, Puppetclass.count
    Environment.importClasses
    flash[:foreman_notice] = "Environments   old:#{ec}\tcurrent:#{Environment.count}<br>PuppetClasses old:#{pc}\tcurrent:#{Puppetclass.count}"
    redirect_to :back
  end

end
