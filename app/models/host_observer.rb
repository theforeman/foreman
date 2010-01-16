class HostObserver < ActiveRecord::Observer
  def after_create(host)
    # get net free ip address from subnet
    # get hostname
    # ...
    # e.g. send out an email that a new host was created
    host.logger.info "trying to create new host #{host.name}" if host.logger
  end

  def after_save(host)
    #create tftp entry
    #create dns entry
    #create dhcp entry
    #....
  end

  def after_update(host)
    #check if anything was changed if we need to update some external netDb
  end

  def after_destroy(host)
    # cleans out the puppet certificate once a host has been deleted
    GW::Puppetca.clean host.name
    #clean up our netDb
  end
end
