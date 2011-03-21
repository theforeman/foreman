# various methods which gets added to the puppetclasses and environments controllers

module Foreman::Controller::Environments

  def import_environments
    @changed = Environment.importClasses
    if @changed["new"].size > 0 or @changed["obsolete"].size > 0
      render :partial => "common/puppetclasses_or_envs_changed", :layout => true
    else
      notice "No changes to your environments detected"
      redirect_to "/" + controller_path
    end
  rescue Exception => e
    error e
    redirect_to "/" + controller_path
  end

  def obsolete_and_new
    if (errors = ::Environment.obsolete_and_new(params[:changed])).empty?
      notice "Succcessfully updated environments and puppetclasses from the on-disk puppet installation"
    else
      error "Failed to update the environments and puppetclasses from the on-disk puppet installation<br/>" + errors.join("<br>")
    end
    redirect_to "/" + controller_path
  end

end
