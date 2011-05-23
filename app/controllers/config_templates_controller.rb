class ConfigTemplatesController < ApplicationController
  include Foreman::Renderer

  def index
    respond_to do |format|
      format.html do
        @search = ConfigTemplate.search params[:search]
        @config_templates = @search.paginate(:page => params[:page], :include => [:template_kind, :environments,:hostgroups])
      end
      format.json { render :json => ConfigTemplate.all}
    end
  end

  def new
    @config_template = ConfigTemplate.new
    @config_template.template_combinations.build
  end

  def create
    @config_template = ConfigTemplate.new(params[:config_template])
    if @config_template.save
      process_success
    else
      process_error
    end
  end

  def edit
    @config_template = ConfigTemplate.find(params[:id])
    @config_template.template_combinations.build if @config_template.template_combinations.empty?
  end

  def update
    @config_template = ConfigTemplate.find(params[:id])
    if @config_template.update_attributes(params[:config_template])
      process_success
    else
      process_error
    end
  end

  def destroy
    @config_template = ConfigTemplate.find(params[:id])
    if @config_template.destroy
      process_success
    else
      process_error
    end
  end

  def build_pxe_default
    if (proxies = Subnet.all.map(&:tftp).uniq.compact).empty?
      error_msg = "No TFTP proxies defined, can't continue"
    end

    if (default_template = ConfigTemplate.find_by_name("PXE Default File")).nil?
      error_msg = "Could not find a Configuration Template with the name \"PXE Default File\", please create one."
    else
      begin
        @profiles = pxe_default_combos
        menu = render_safe(default_template.template, [:default_template_url], {:profiles => @profiles})
      rescue => e
        error_msg = "failed to process template: #{e}"
      end
    end

    unless error_msg.empty?
      respond_to do |format|
        format.html { error(error_msg) and return redirect_to(:back)}
        format.json { render :json => error_msg, :status => :unprocessable_entity and return }
      end
    end

    error_msgs = []
    proxies.each do |proxy|
      begin
        tftp = ProxyAPI::TFTP.new(:url => proxy.url)
        tftp.create_default({:menu => menu})

        @profiles.each do |combo|
          combo[:hostgroup].operatingsystem.pxe_files(combo[:hostgroup].medium, combo[:hostgroup].architecture).each do |bootfile_info|
            for prefix, path in bootfile_info do
              tftp.fetch_boot_file(:prefix => prefix.to_s, :path => path)
            end
          end
        end
      rescue Exception => exc
        error_msgs << "#{proxy}: #{exc.message}"
      end
    end

    unless error_msgs.empty?
      msg = "There was an error creating the PXE Default file: #{error_msgs.join(",")}"
      respond_to do |format|
        format.html { error msg and return redirect_to :back}
        format.json { render :json => msg, :status => 500 and return }
      end
    end

    respond_to do |format|
      format.html { notice "PXE Default file has been deployed to all Smart Proxies" }
      format.json { head :status => :ok and return }
    end
    redirect_to :back
  end

  private

  # get a list of all hostgroup, template combinations that a pxemenu will be
  #  generated for
  def pxe_default_combos
    combos = []
    ConfigTemplate.template_kind_name_eq("provision").each do |template|
      template.template_combinations.each do |combination|
        hostgroup = combination.hostgroup
        if hostgroup and hostgroup.operatingsystem and hostgroup.architecture and hostgroup.medium
          combos << {:hostgroup => hostgroup, :template => template}
        end
      end
    end
    combos
  end

  def default_template_url template, hostgroup
    url_for :only_path => false, :action => :template, :controller => :unattended, :id => template.name, :hostgroup => hostgroup.name
  end

end