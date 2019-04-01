module Resolvers
  module Domain
    class Subnets < Resolvers::BaseResolver
      type [Types::Subnet], null: true

      argument :location, String, required: false
      argument :type, String, required: false

      def resolve(args)
        includes = [:domains]
        includes << { taxable_taxonomies: :taxonomy } if args[:location]

        scope = lambda do |scope|
          scope.includes(includes)
            .where(domains: { id: object.id })
            .try { |query| args[:location] ? query.where(taxonomies: { type: 'Location', name: args[:location] }) : query }
            .try { |query| args[:type] ? query.where(type: args[:type]) : query }
        end

        CollectionLoader.for(object.class, :subnets, scope).load(object)
      end
    end
  end
end
