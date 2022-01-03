module Foreman::Controller::Puppet::HostsControllerExtensions
  extend ActiveSupport::Concern

  MULTIPLE_EDIT_ACTIONS = %w(select_multiple_puppet_ca_proxy update_multiple_puppet_ca_proxy)

  included do
    before_action :find_multiple_for_puppet_host_extensions, :only => MULTIPLE_EDIT_ACTIONS
    before_action :validate_multiple_puppet_ca_proxy, :only => :update_multiple_puppet_ca_proxy

    define_action_permission MULTIPLE_EDIT_ACTIONS, :edit
  end

  def validate_multiple_puppet_ca_proxy
    validate_multiple_proxy(select_multiple_puppet_ca_proxy_hosts_path)
  end

  def validate_multiple_proxy(redirect_path)
    if params[:proxy].nil? || (proxy_id = params[:proxy][:proxy_id]).nil?
      error _('No proxy selected!')
      redirect_to(redirect_path)
      return false
    end

    if proxy_id.present? && !SmartProxy.find_by_id(proxy_id)
      error _('Invalid proxy selected!')
      redirect_to(redirect_path)
      false
    end
  end

  def update_multiple_proxy(proxy_type, host_update_method)
    proxy_id = params[:proxy][:proxy_id]
    if proxy_id
      proxy = SmartProxy.find_by_id(proxy_id)
    else
      proxy = nil
    end

    failed_hosts = {}

    @hosts.each do |host|
      host.send(host_update_method, proxy)
      host.save!
    rescue => error
      failed_hosts[host.name] = error
      message = _('Failed to set %{proxy_type} proxy for %{host}.') % {:host => host, :proxy_type => proxy_type}
      Foreman::Logging.exception(message, error)
    end

    if failed_hosts.empty?
      if proxy
        success _('The %{proxy_type} proxy of the selected hosts was set to %{proxy_name}') % {:proxy_name => proxy.name, :proxy_type => proxy_type}
      else
        success _('The %{proxy_type} proxy of the selected hosts was cleared.') % {:proxy_type => proxy_type}
      end
    else
      error n_("The %{proxy_type} proxy could not be set for host: %{host_names}.",
        "The %{proxy_type} puppet ca proxy could not be set for hosts: %{host_names}",
        failed_hosts.count) % {:proxy_type => proxy_type, :host_names => failed_hosts.map { |h, err| "#{h} (#{err})" }.to_sentence}
    end
    redirect_back_or_to hosts_path
  end

  def handle_proxy_messages(errors, proxy, proxy_type)
    if errors.empty?
      if proxy
        success _('The %{proxy_type} proxy of the selected hosts was set to %{proxy_name}.') % {:proxy_name => proxy.name, :proxy_type => proxy_type}
      else
        success _('The %{proxy_type} proxy of the selected hosts was cleared.') % {:proxy_type => proxy_type}
      end
    else
      error n_("The %{proxy_type} proxy could not be set for host: %{host_names}.",
        "The %{proxy_type} puppet ca proxy could not be set for hosts: %{host_names}",
        errors.count) % {:proxy_type => proxy_type, :host_names => errors.map { |h, err| "#{h} (#{err})" }.to_sentence}
    end
  end

  def select_multiple_puppet_ca_proxy
  end

  def update_multiple_puppet_ca_proxy
    update_multiple_proxy(_('Puppet CA'), :puppet_ca_proxy=)
  end

  def find_multiple_for_puppet_host_extensions
    find_multiple
  end
end
