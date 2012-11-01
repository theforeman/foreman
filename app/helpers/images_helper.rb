module ImagesHelper
  def openstack_list_of_images(compute_resource)
    compute_resource.vms.first.list_images
  end
end
