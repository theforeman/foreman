module TaxableSubnet
  extend ActiveSupport::Concern
  include Taxonomix

  included do
    default_scope lambda {
      with_taxonomy_scope do
        order(:vlanid)
      end
    }
  end

  module ClassMethods
    def taxable_type
      'Subnet'
    end
  end

  # overwrite method in taxonomix, since subnet is not direct association of host anymore
  def used_taxonomy_ids(type)
    return [] if new_record?
    Host::Base.joins(:primary_interface).where(:nics => {:subnet_id => id}).distinct.pluck(type).compact
  end
end
