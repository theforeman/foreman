class KeyPairsController < ApplicationController
  include Foreman::Controller::ComputeResourcesCommon

  before_action :find_compute_resource, :except => [:show]
  before_action :find_resource, :only => [:show]

  def index
    @key_pairs = @compute_resource.get_compute_key_pairs
  rescue => e
    compute_resource_error("SSH keys", e)
  end

  def show
    @key_pair.update(audit_comment: _("%{user} Downloaded %{key} as pem file") % {user: User.current.name, key: @key_pair.name})
    send_data @key_pair.secret, :filename => "#{@key_pair.name}.pem"
  end

  def create
    if @compute_resource.recreate
      process_success :success_msg => _('Successfully recreated'),
                      :success_redirect => compute_resource_path(@compute_resource)
    else
      process_error :error_msg => _('Could not recreate a new SSH key')
    end
  end

  def destroy
    key_to_delete = params[:id]
    return not_found unless key_to_delete
    if @compute_resource.delete_key_from_resource(key_to_delete)
      process_success :success_msg => _('Successfully delete %s') % key_to_delete,
                      :success_redirect => compute_resource_path(@compute_resource)
    else
      process_error :error_msg => _('Could not delete %s') % key_to_delete
    end
  end

  private

  def find_compute_resource
    @compute_resource = ComputeResource.find(params[:compute_resource_id])
    return not_found unless @compute_resource.capabilities.include?(:key_pair)
    @compute_resource
  end

  def find_resource
    @key_pair = KeyPair.find(params[:id])
  end

  def action_permission
    case params[:action]
      when 'download'
        :view
      when 'create'
        :destroy
      else
        super
    end
  end
end
