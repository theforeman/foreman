# various methods which gets added to the puppetclasses and environments controllers

module Foreman::Controller::Environments

  def import_environments
    begin
      opts      = params[:proxy].blank? ? { } : { :url => SmartProxy.find(params[:proxy]).try(:url) }
      @importer = PuppetClassImporter.new(opts)
      @changed  = @importer.changes
    rescue => e
      if e.message =~ /puppet feature/i
        error "We did not find a foreman proxy that can provide the information, ensure that you have at least one Proxy with the puppet feature turned on."
        redirect_to :controller => controller_path and return
      else
        raise e
      end
    end

    if @changed["new"].size > 0 or @changed["obsolete"].size > 0 or @changed["updated"].size > 0
      render "common/_puppetclasses_or_envs_changed"
    else
      notice "No changes to your environments detected"
      redirect_to :controller => controller_path
    end
  end

  def obsolete_and_new
    if (errors = ::PuppetClassImporter.new.obsolete_and_new(params[:changed])).empty?
      notice "Successfully updated environments and puppetclasses from the on-disk puppet installation"
    else
      error "Failed to update the environments and puppetclasses from the on-disk puppet installation<br/>" + errors.join("<br>")
    end
    redirect_to :controller => controller_path
  end

end