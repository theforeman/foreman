module Resolvers
  module Domain
    class Subnets < Resolvers::BaseResolver
      type [Types::Subnet], null: true

      argument :location, String, required: false
      argument :type, String, required: false

      def resolve(args)
        includes = [:domains]

        scope = lambda do |scope|
          join_taxonomies(scope, args).includes(includes)
            .where(domains: { id: object.id })
            .try { |query| args[:location] ? query.where(taxonomies: { type: 'Location', name: args[:location] }) : query }
            .try { |query| args[:type] ? query.where(type: args[:type]) : query }
        end
        CollectionLoader.for(object.class, :subnets, scope).load(object)
      end

      private

      def join_taxonomies(scope, args)
        return scope unless args[:location]
        scope.joins("LEFT OUTER JOIN taxable_taxonomies ON taxable_taxonomies.taxable_id = #{scope.table_name}.id
                     LEFT OUTER JOIN taxonomies ON taxable_taxonomies.taxonomy_id = taxonomies.id")
      end
    end
  end
end
