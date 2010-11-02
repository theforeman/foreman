# various methods which gets added to the puppetclasses and environments controllers

module Foreman::Controller::Environments

  def import_environments
    @changed = Environment.importClasses
    if @changed[:obsolete][:environments].size > 0 or @changed[:obsolete][:puppetclasses].size > 0 or
      @changed[:new][:environments].size > 0       or @changed[:new][:puppetclasses].size > 0
      @grouping = 3
      render :partial => "common/puppetclasses_or_envs_changed", :layout => true
    else
      redirect_to :back
    end
  rescue Exception => e
    flash[:foreman_error] = e
    redirect_to :back
  end

  def obsolete_and_new
    if params[:commit] == "Cancel"
      redirect_to environments_path
    else
      if (errors = Environment.obsolete_and_new(params[:changed])).empty?
        flash[:foreman_notice] = "Succcessfully updated environments and puppetclasses from the on-disk puppet installation"
      else
        flash[:foreman_error]  = "Failed to update the environments and puppetclasses from the on-disk puppet installation<br/>" + errors
      end
      redirect_to :back
    end
  end

  protected
  def no_puppetclass_documentation_handler(exception)
    if exception.message =~ /No route matches "\/puppet\/rdoc\/([^\/]+)\/classes\/(.+?)\.html/
      render :template => "puppetclasses/no_route", :locals => {:environment => $1, :name => $2.gsub("/","::")}, :layout => false
    else
      if local_request?
        rescue_action_locally exception
      else
        rescue_action_in_public exception
      end
    end
  end

end
