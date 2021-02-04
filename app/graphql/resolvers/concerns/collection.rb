module Resolvers
  module Concerns
    module Collection
      extend ActiveSupport::Concern

      included do
        type ["Types::#{self::MODEL_CLASS}".safe_constantize], null: false

        argument :search, String, 'Search query', required: false
        argument :sort_by, String, 'Sort by this searchable field', required: false
        argument :sort_direction, Types::SortDirectionEnum, 'Sort direction', required: false
        argument :pagination, Types::PaginationInput, 'Pagination', required: false

        if has_taxonomix?
          argument :location, String, required: false
          argument :location_id, String, required: false
          argument :organization, String, required: false
          argument :organization_id, String, required: false
        end

        delegate :has_taxonomix?, to: :class
      end

      def resolve(**kwargs)
        filters = filter_list(**kwargs)

        base_scope = authorized_scope.all
        filters.reduce(base_scope) { |scope, filter| filter.call(scope) }
      end

      private

      def user
        context[:current_user]
      end

      def model_class
        self.class::MODEL_CLASS
      end

      def authorized_scope
        return model_class unless model_class.respond_to?(:authorized)

        permission = model_class.find_permission_name(:view)
        model_class.authorized_as(user, permission, model_class)
      end

      def search_options(search:, sort_by:, sort_direction:)
        (sort_direction.to_s.upcase == 'DESC') ? 'DESC' : 'ASC'
        search_options = [search]
        if sort_by.present?
          search_options << { order: "#{sort_by} #{sort_direction}".strip }
        end
        search_options
      end

      def filter_list(search: nil, sort_by: nil, sort_direction: 'ASC', pagination: nil,
                      first: nil, skip: nil,
                      location: nil, location_id: nil,
                      organization: nil, organization_id: nil)
        filters = []

        if search.present? || sort_by.present?
          filters << search_and_sort_filter(search: search, sort_by: sort_by, sort_direction: sort_direction)
        end

        if has_taxonomix?
          taxonomy_ids = taxonomy_ids_for_filter(location_id: location_id, organization_id: organization_id,
                                                 location: location, organization: organization)
          filters << taxonomy_id_filter(taxonomy_ids) if taxonomy_ids.any?
        end

        if pagination
          filters << pagination_filter(pagination)
        end

        filters
      end

      def search_and_sort_filter(search:, sort_by:, sort_direction:)
        lambda do |scope|
          scope.search_for(*search_options(search: search, sort_by: sort_by, sort_direction: sort_direction))
        rescue ScopedSearch::QueryNotSupported => error
          raise GraphQL::ExecutionError.new(error.message)
        end
      end

      def taxonomy_id_filter(taxonomy_ids)
        lambda do |scope|
          scope.joins(:taxable_taxonomies)
            .where(taxable_taxonomies: {taxonomy_id: taxonomy_ids}).distinct
        end
      end

      def taxonomy_ids_for_filter(location_id: nil, organization_id: nil,
                                  location: nil, organization: nil)
        taxonomy_ids = []

        if location_id.present?
          taxonomy_ids << resolve_taxonomy_global_id(Location, location_id)
        elsif location.present?
          taxonomy_ids << resolve_taxonomy_name_to_id(Location, location)
        end

        if organization_id.present?
          taxonomy_ids << resolve_taxonomy_global_id(Organization, organization_id)
        elsif organization.present?
          taxonomy_ids << resolve_taxonomy_name_to_id(Organization, organization)
        end

        taxonomy_ids.uniq
      end

      def pagination_filter(pagination)
        lambda do |scope|
          scope.paginate(page: pagination.page, per_page: pagination.per_page)
        rescue ScopedSearch::QueryNotSupported => e
          raise GraphQL::ExecutionError, e.message
        end
      end

      def resolve_taxonomy_global_id(taxonomy_class, global_id)
        taxonomy_name = taxonomy_class.name
        _, type_name, id = Foreman::GlobalId.decode(global_id)

        raise GraphQL::ExecutionError.new("Global ID for #{taxonomy_name} filter is for other graphql type (expected '#{taxonomy_name}', got '#{type_name}')") unless taxonomy_name == type_name

        id.to_i
      end

      def resolve_taxonomy_name_to_id(taxonomy_class, taxonomy_name)
        id = taxonomy_class.find_by(name: taxonomy_name)
        raise GraphQL::ExecutionError.new("#{taxonomy_class.name} could not be found my name #{name}.") unless id
        id
      end

      class_methods do
        def has_taxonomix?
          self::MODEL_CLASS.include?(Taxonomix)
        end
      end
    end
  end
end
