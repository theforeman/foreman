# various methods which gets added to the puppetclasses and environments controllers

module Foreman::Controller::Environments
  extend ActiveSupport::Concern

  def import_environments
    begin
      opts = params[:proxy].blank? ? { } : { :url => SmartProxy.find(params[:proxy]).try(:url) }
      opts[:env] = params[:env] unless params[:env].blank?
      @importer = PuppetClassImporter.new(opts)
      @changed  = @importer.changes
    rescue => e
      if e.message =~ /puppet feature/i
        error _("No smart proxy was found to import environments from, ensure that at least one smart proxy is registered with the 'puppet' feature.")
        redirect_to :controller => controller_path
      else
        raise e
      end
    end

    if @changed["new"].size > 0 || @changed["obsolete"].size > 0 || @changed["updated"].size > 0
      render "common/_puppetclasses_or_envs_changed"
    else
      notice _("No changes to your environments detected")
      redirect_to :controller => controller_path
    end
  end

  def obsolete_and_new
    if (errors = ::PuppetClassImporter.new.obsolete_and_new(params[:changed])).empty?
      notice _("Successfully updated environments and Puppet classes from the on-disk Puppet installation")
    else
      error _("Failed to update environments and Puppet classes from the on-disk Puppet installation: %s") % errors.to_sentence
    end
    redirect_to :controller => controller_path
  end
end
