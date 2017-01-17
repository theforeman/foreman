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

    if @importer.ignored_boolean_environment_names?
      warning(_("Ignored environment names resulting in booleans found. Please quote strings like true/false and yes/no in config/ignored_environments.yml."))
    end

    if @changed["new"].size > 0 || @changed["obsolete"].size > 0 || @changed["updated"].size > 0
      render "common/_puppetclasses_or_envs_changed"
    else
      notice_message = _("No changes to your environments detected")

      if @changed['ignored'].present?
        list_ignored(notice_message, @changed['ignored'])
      end

      notice(notice_message)
      redirect_to :controller => controller_path
    end
  end

  def obsolete_and_new
    import_params = { :changed => params[:changed] }
    if params[:commit] == _("Update on background")
      ForemanTasks.async_task(::Actions::Foreman::PuppetClass::Import, import_params)
      notice _("Added import task to the queue, it will be run shortly")
    else
      ForemanTasks.sync_task(::Actions::Foreman::PuppetClass::Import, import_params)
      begin
        notice _('Successfully updated environments and Puppet classes from the on-disk Puppet installation')
      rescue ForemanTasks::TaskError
        error _('Failed to update environments and Puppet classes from the Puppet installation')
      end
    end
  rescue ::Foreman::Exception => e
    error _("Failed to add task to queue: %s") % e.to_s
  ensure
    redirect_to :controller => controller_path
  end

  private

  def list_ignored(notice, ignored)
    environments = ignored.select { |_, values| values.first == '_ignored_' }
    if environments.any?
      ignore_notice = _("Ignored environments: %s") % environments.keys.to_sentence
    else
      ignore_notice = _("Ignored classes in the environments: %s") % ignored.keys.to_sentence
    end

    notice << "\n" + ignore_notice
  end
end
