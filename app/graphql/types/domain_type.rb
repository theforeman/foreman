Types::DomainType = GraphQL::ObjectType.define do
  name 'Domain'
  description 'A Domain'

  backed_by_model :domain do
    attr :id
    attr :name
    attr :fullname
  end

  connection :subnets, Types::SubnetType.connection_type do
    argument :type, types.String

    resolve(proc do |obj, args|
      AssociationLoader.for(obj.class, :subnets).load(obj).then do |subnets|
        if args[:type].present?
          subnets.select { |s| s.type == args[:type] }
        else
          subnets
        end
      end
    end)
  end
end
