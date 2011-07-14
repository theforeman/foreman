class HostObserver < ActiveRecord::Observer

  def after_destroy(host)
    return true if Rails.env == "test" or host.puppetca?
    return true unless Setting[:manage_puppetca]

    GW::Puppetca.clean host.name
  end
end
