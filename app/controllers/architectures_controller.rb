class ArchitecturesController < ApplicationController
  include ApplicationHelper
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Architecture

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @architectures ||= resource_base_search_and_page.includes(:operatingsystems)
    respond_to do |format|
      format.html do
        render "index"
      end
      format.json do
        render json: {
          rows: rows(@architectures),
          columns: columns,
          total_entries: @architectures.total_entries,
          global_actions: global_actions,
          primary_action: primary_action,
          before_toolbar_content: before_toolbar_content,
          empty_state: empty_state,
        }, status: :ok
      end
    end
  end

  def new
    @architecture = Architecture.new
  end

  def create
    @architecture = Architecture.new(architecture_params)
    if @architecture.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @architecture.update(architecture_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @architecture.destroy
      process_success
    else
      process_error
    end
  end

  private

  def columns
    [js_sortable_col(_('Name'), 'name'), _('Operating systems'), _('Hosts')]
  end

  def rows(architectures)
    @architectures_hosts_count ||= hosts_count(:architecture)
    architectures.map do |arch|
      name = js_link_if_can_edit(arch, edit_architecture_path(:id => arch), arch.name)
      os = arch.operatingsystems.map(&:to_label).to_sentence
      hosts_count = js_link_to(@architectures_hosts_count[arch], hosts_path(:search => "architecture = #{arch}"))
      { cells: [name, os, hosts_count], actions: row_actions(arch) }
    end
  end

  def row_actions(arch)
    [
      js_delete_if_authorized(
        model_id: arch.id,
        path: architecture_path(:id => arch),
        message: _("Delete %s?") % arch.name
      ),
    ]
  end

  def global_actions
    []
  end

  def primary_action
    js_link_to(_("Create"), new_architecture_path)
  end

  def before_toolbar_content
  end

  def empty_state
    description = _('Before you proceed to using Foreman you should provide information about one or more architectures.<br>
    Each entry represents a particular hardware architecture, most commonly <strong>x86_64</strong> or <strong>i386</strong>.<br>
    Foreman also supports the Solaris operating system family, which includes sparc based systems.<br>
    Each architecture can also be associated with more than one operating system and a selector block is provided to allow you to select valid combinations.')
    @empty_state ||= {
      header: _('Architectures'),
      icon: 'building',
      iconType: 'fa',
      description: description,
      action: js_empty_state_action(_("Create Architecture"), new_architecture_path),
    }
  end
end
