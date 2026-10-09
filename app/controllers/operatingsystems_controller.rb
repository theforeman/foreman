class OperatingsystemsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Operatingsystem

  before_action :find_resource, :only => [:edit, :update, :destroy, :clone, :new_boot_file_download, :download_boot_files]

  def index
    @operatingsystems = resource_base_search_and_page.includes(:media, :architectures)
    @boot_file_proxies = SmartProxy.authorized(:view_smart_proxies).with_features('TFTP').to_a
  end

  def download_boot_files
    source = params.require(:source).permit(:type, :id, :content_source_id)
    result = Foreman::BootloaderUniverse::Download.new(
      operatingsystem: @operatingsystem,
      source: source
    ).call
    accepted = result[:results].count { |entry| entry[:accepted] }
    failed = result[:results].reject { |entry| entry[:accepted] }
    warnings = Array(result[:warnings]) + failed.map { |entry| "#{entry[:smart_proxy_id]} (#{entry[:architecture]}): #{entry[:error]}" }
    if warnings.any?
      warning(warnings.join('; '))
    elsif accepted.positive?
      success(n_('Downloading boot files via %{count} proxy',
        'Downloading boot files via %{count} proxies', accepted) % { count: accepted })
    end
    redirect_to operatingsystems_path
  rescue Foreman::BootloaderUniverse::Download::InvalidRequest => e
    error(e.message)
    redirect_to operatingsystems_path
  end

  def new_boot_file_download
  end

  def new
    @operatingsystem = Operatingsystem.new
  end

  def create
    @operatingsystem = Operatingsystem.new(operatingsystem_params)
    if @operatingsystem.save
      process_success
    else
      process_error
    end
  end

  def edit
    # Generates default OS template entries
    @operatingsystem.provisioning_templates.group_by(&:template_kind_id).each do |kind, templates|
      if @operatingsystem.os_default_templates.where(:template_kind_id => kind).blank?
        @operatingsystem.os_default_templates.build(
          :template_kind_id => kind,
          :provisioning_template => (templates.first if templates.one?)
        )
      end
    end
  end

  def update
    if @operatingsystem.update(operatingsystem_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @operatingsystem.destroy
      process_success
    else
      process_error
    end
  end

  def clone
    @operatingsystem = @operatingsystem.deep_clone include: [:media, :ptables, :architectures, :os_parameters], except: [:title]
  end

  private

  def action_permission
    case params[:action]
      when 'clone'
        :create
      when 'new_boot_file_download', 'download_boot_files'
        :edit
      else
        super
    end
  end
end
