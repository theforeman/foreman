class VolumesController < ApplicationController
  before_filter :find_compute_resource

  def index
    # Listing volumes in /hosts/new consumes this method as JSON
    values = @compute_resource.volumes.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @volumes = values.paginate :page => params[:page] }
      format.json { render :json => values }
    end
  end

  def sync 
    old_uuids = @compute_resource.volumes.map(&:uuid)
    sync_stats = create_update_volumes(old_uuids)
    new_uuids = @compute_resource.volumes.map(&:uuid)
    sync_stats[:removed] = clean_old_volumes(old_uuids - new_uuids)

    message =  _("Sync completed: <br/>") 
    message += _(" - %s volumes created <br/>") % sync_stats[:created]
    message += _(" - %s volumes updated <br/>") % sync_stats[:updated]
    message += _(" - %s volumes removed <br/>") % sync_stats[:removed]
     
    process_success(:success_redirect => compute_resource_path(@compute_resource), 
                    :success_msg      => message)
  end


  private

  def find_compute_resource
    @compute_resource = ComputeResource.find(params[:compute_resource_id])
  end

  def create_update_volumes(uuids)
    counter = { :updated => 0, :created => 0 }
    @compute_resource.available_volumes.each do |volume|
      if uuids.include?(volume.id)
        #update attributes
        counter[:updated] += 1
      else
        @compute_resource.volumes.create(:name => volume.name, :uuid => volume.id,
                                         :size => volume.size, :status => volume.status, 
                                         :availability_zone => volume.availability_zone) 
        counter[:created] += 1
      end
    end
    
    counter
  end

  def clean_old_volumes(uuids)
    counter = 0
    uuids.each do |uuid|
      if (old_volume = @compute_resource.volumes.find_by_uuid(uuid))
        old_volume.destroy
        counter += 1
      end
    end
   
    counter
  end
end
