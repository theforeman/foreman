module Hostmix
  def self.included(base)

    base.class_eval do
      def self.add_host_associations(relation, extras={})
        if relation == :has_many
          has_many :hosts, extras.merge({:class_name => 'Host::Managed'})
        elsif relation == :belongs_to
          belongs_to :host, extras.merge({:class_name => 'Host::Managed'})
        end
      end
    end
  end

end
