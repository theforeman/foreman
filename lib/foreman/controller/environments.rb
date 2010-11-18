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
    error e
    redirect_to :back
  end

  def obsolete_and_new
    if (errors = Environment.obsolete_and_new(params[:changed])).empty?
      notice "Succcessfully updated environments and puppetclasses from the on-disk puppet installation"
    else
      error "Failed to update the environments and puppetclasses from the on-disk puppet installation<br/>" + errors.join("<br>")
    end
    redirect_to puppetclasses_path
  end

end
