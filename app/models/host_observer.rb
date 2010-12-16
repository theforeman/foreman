class HostObserver < ActiveRecord::Observer
  def after_create(host)
  end

  def after_save(host)
  end

  def after_update(host)
  end

  def after_destroy(host)
    GW::Puppetca.clean host.name
  end
end
