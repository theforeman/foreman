# various methods which gets added to the puppetclasses and environments controllers

module Foreman::Controller::Environments

  def import_environments
    begin
      @changed = Environment.importClasses(params[:proxy], params[:name])
    rescue => e
      if e.message =~ /puppet feature/i
        error "We did not find a foreman proxy that can provide the information, ensure that you have at least one Proxy with the puppet feature turned on."
        redirect_to "/" + controller_path and return
      else
        raise e
      end
    end

    respond_to do |format|
      format.html do
        if @changed["new"].size > 0 or @changed["obsolete"].size > 0
          render "common/_puppetclasses_or_envs_changed"
        else
          notice "No changes to your environments detected"
          redirect_to "/" + controller_path
        end
      end
      format.json do
        if not params[:batch]
          process_error
        else
          changed = { :new => @changed["new"], :obsolete => @changed["obsolete"] } 
          [:new, :obsolete].each { |kind| changed[kind].each_key { |k| @changed[kind.to_s][k] = @changed[kind.to_s][k].inspect } }
          render :json => ::Environment.obsolete_and_new(changed)
        end
      end
    end
  end

  def obsolete_and_new
    if (errors = ::Environment.obsolete_and_new(params[:changed])).empty?
      notice "Successfully updated environments and puppetclasses from the on-disk puppet installation"
    else
      error "Failed to update the environments and puppetclasses from the on-disk puppet installation<br/>" + errors.join("<br>")
    end
    redirect_to "/" + controller_path
  end

end
