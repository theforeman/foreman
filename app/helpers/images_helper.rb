module ImagesHelper
  def openstack_list_of_images
    hash = {}
    ComputeResource.first.vms.first.connection.list_images.body['images'].each { |image| hash[image['id']] = image['name']}   

    hash
  end
end
