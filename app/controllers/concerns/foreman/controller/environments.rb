# various methods which gets added to the puppetclasses and environments controllers

module Foreman::Controller::Environments
  extend ActiveSupport::Concern

  def import_environments
    begin
      opts = params[:proxy].blank? ? { } : { :url => SmartProxy.find(params[:proxy]).try(:url) }
      opts[:env] = params[:env] if params[:env].present?
      @importer = PuppetClassImporter.new(opts)
      @changed  = @importer.changes
    rescue => e
      if e.message =~ /puppet feature/i
        error _("No smart proxy was found to import environments from, ensure that at least one smart proxy is registered with the 'puppet' feature")
        redirect_to :controller => controller_path
      else
        raise e
      end
    end

    if @importer.ignored_boolean_environment_names?
      warning(_("Ignored environment names resulting in booleans found. Please quote strings like true/false and yes/no in config/ignored_environments.yml"))
    end

    if !@changed["new"].empty? || !@changed["obsolete"].empty? || !@changed["updated"].empty?
      render "common/_puppetclasses_or_envs_changed"
    else
      info_message = _("No changes to your environments detected")

      if @changed['ignored'].present?
        list_ignored(info_message, @changed['ignored'])
      end

      info info_message
      redirect_to :controller => controller_path
    end
  end

  def obsolete_and_new
    if (errors = ::PuppetClassImporter.new.obsolete_and_new(params[:changed])).empty?
      success _("Successfully updated environments and Puppet classes from the on-disk Puppet installation")
    else
      error _("Failed to update environments and Puppet classes from the on-disk Puppet installation: %s") % errors.to_sentence
    end
    redirect_to :controller => controller_path
  end

  private

  def list_ignored(info_message, ignored)
    environments = ignored.select { |_, values| values.first == '_ignored_' }
    if environments.any?
      ignore_info = _("Ignored environments: %s") % environments.keys.to_sentence
    else
      ignore_info = _("Ignored classes in the environments: %s") % ignored.keys.to_sentence
    end

    info_message << "\n" + ignore_info
  end
end
