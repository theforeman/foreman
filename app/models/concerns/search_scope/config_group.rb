module SearchScope
  module ConfigGroup
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => true
      scoped_search :on => :hosts_count
      scoped_search :on => :hostgroups_count
      scoped_search :on => :config_group_classes_count
    end
  end
end
