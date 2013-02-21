module Host
  module ActsAsHostable
    extend ActiveSupport::Concern
 
    included do
      if column_names.include? "host_id"
        belongs_to :host, :class_name => 'Host::Managed'
      elsif column_names.include? "reference_id"
        belongs_to :host, :class_name => 'Host::Managed', :foreign_key => "reference_id"
      else
        has_many :hosts, :class_name => 'Host::Managed'
    end
 
    module ClassMethods
      def acts_as_hostable(options = {})
        # your code will go here
      end
    end
  end
end

ActiveRecord::Base.send :include, Host::ActsAsHostable