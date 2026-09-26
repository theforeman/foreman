module Oidc
  class ClaimReader
    def initialize(claims)
      @claims = claims
    end

    def read(path)
      path.to_s.split('.').reduce(claims) do |value, component|
        break nil unless value.is_a?(Hash)

        value[component]
      end
    end

    private

    attr_reader :claims
  end
end
