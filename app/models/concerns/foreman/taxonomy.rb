module Foreman
  module Taxonomy

    # Concern to be mixed in all taxonomy subclasses to get common shared methods.
    # Currently it relies on looking up the reflection of the opposite taxonomy,
    # but it can be extended to support several reflections
    module Shared
      extend ActiveSupport::Concern

      module ClassMethods
        def taxonomy_type
          model_name.singular
        end

        # This should change significantly to accomodate > 2 taxonomy types
        def opposite_type
          case taxonomy_type
          when 'location'
            'organization'
          when 'organization'
            'location'
          end
        end

        def my_taxonomy_sql_conditions
          if User.current.admin?
            {}
          else
            sanitize_sql_for_conditions([" (taxonomies.id in (?))",
                                         User.current.send("#{taxonomy_type}_and_child_ids")])
          end
        end
      end

      included do
        #include Foreman::ThreadSession::TaxonomyModel
        include Parameterizable::ByIdName
        include ParameterValidators

        extend FriendlyId
        friendly_id :title

        has_many "#{taxonomy_type}_parameters".to_sym,
                   :class_name  => "#{taxonomy_type.classify}Parameter",
                   :foreign_key => :reference_id,
                   :dependent   => :destroy,
                   :inverse_of  => taxonomy_type.to_sym

        has_many :default_users, :class_name  => 'User',
                                 :foreign_key => "default_#{taxonomy_type}_id".to_sym,
                                 :dependent   => :nullify
        has_and_belongs_to_many opposite_type.pluralize.to_sym
        accepts_nested_attributes_for "#{taxonomy_type}_parameters".to_sym, :allow_destroy => true
        has_many_hosts :dependent => :nullify

        scope :completer_scope, lambda { |opts| send("my_#{taxonomy_type.pluralize}") }
        scope "my_#{taxonomy_type.pluralize}".to_sym, lambda { where(my_taxonomy_sql_conditions) }
      end

      def lookup_value_match
        "#{self.class.taxonomy_type}=#{title}"
      end

      def sti_name
        _("#{self.class.taxonomy_type}")
      end

      def dup
        new = super
        new.name = ""
        new.users             = users
        new.environments      = environments
        new.smart_proxies     = smart_proxies
        new.subnets           = subnets
        new.compute_resources = compute_resources
        new.config_templates  = config_templates
        new.media             = media
        new.domains           = domains
        new.realms            = realms
        new.media             = media
        new.hostgroups        = hostgroups
        new.send("#{self.class.opposite_type.pluralize.to_sym}=",
                    self.send(self.class.opposite_type.pluralize.to_sym))
        new
      end

      # Returns self and ancestors parameters as a hash - should be in NestedAncestryCommon
      def parameters(include_source = false)
        hash = {}
        ids = ancestor_ids
        ids << id unless new_record? || frozen?
        # Need to pull out the taxonomies to ensure they are sorted first,
        # otherwise we might be overwriting the hash in the wrong order.
        taxonomies = find_and_sort_taxonomies(ids)

        taxonomies.each do |taxonomy|
          taxonomy.send("#{self.class.taxonomy_type}_parameters".to_sym).each do |param|
            hash[param.name] = param_value_helper(include_source, param, taxonomy)
          end
        end
        hash
      end

      private

      def param_value_helper(include_source, param, taxonomy)
        if include_source
          { :value => param.value,
            :source => N_("#{self.class.taxonomy_type}").to_sym,
            :source_name => taxonomy.title }
        else
          param.value
        end
      end

      def find_and_sort_taxonomies(ids)
        if ids.size == 1
          [self]
        else
          self.class.sort_by_ancestry(self.class
                                      .includes("#{self.class.taxonomy_type}_parameters".to_sym)
                                      .find(ids))
        end
      end
    end
  end
end
