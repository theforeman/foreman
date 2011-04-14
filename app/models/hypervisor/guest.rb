require_dependency 'virt/guest'

class Virt::Guest

  def self.all
    Virt.connection.host.guests.values.flatten.sort
  end

  def self.find(name)
    Virt.connection.host.find_guest_by_name name
  rescue
    raise ActiveRecord::RecordNotFound
  end

  def to_param
    to_s
  end

  def as_json opts
    {to_s => {:memory => memory, :vcpu => vcpu, :running => running?, :volume => {:size => volume.size, :pool => volume.pool.name}}}
  end

end