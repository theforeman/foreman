module System
  module Systemmix

      def has_many_systems(options = {})
        has_many :systems, {:class_name => "System::Managed"}.merge(options)
      end

      def belongs_to_system(options = {})
        belongs_to :system, {:class_name => "System::Managed", :foreign_key => :system_id}.merge(options)
      end

  end
end