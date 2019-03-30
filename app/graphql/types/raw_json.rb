module Types
  class RawJson < GraphQL::Schema::Scalar
    def self.coerce_input(val, ctx)
      val
    end

    def self.coerce_result(val, ctx)
      val
    end
  end
end
