class HostObserver < ActiveRecord::Observer

  def after_destroy(host)
    return true if Rails.env == "test" or host.puppetca?

    GW::Puppetca.clean host.name
  end
end
