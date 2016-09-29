# DestroyFlag adds a flag and a corresponding reader method to any active record
# during deletion. The flag is set to true using before_destroy callback so during
# complicated association deletions you can check whether the deletion includes
# the object, e.g. we normally prevent deletion of primary interface in it's
# before filter but we have to allow it when we delete associated host.
#
#  class Host
#    include DestroyFlag
#  end
#
#  class Nic
#    belongs_to :host
#    before_destroy :keep_primary, :if => Proc.new { |nic| nic.primary? }
#
#    def keep_primary
#      unless host.being_destroyed?           # Here we use being_destroyed? flag
#        raise 'we can not delete primary'
#      end
#    end
#  end
#
module DestroyFlag
  extend ActiveSupport::Concern

  def being_destroyed?
    @_active_record_being_destroyed
  end

  included do
    attr_accessor :_active_record_being_destroyed
    before_destroy { |record| record._active_record_being_destroyed = true }
  end
end
