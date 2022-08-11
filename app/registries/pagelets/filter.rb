module Pagelets
  class Filter
    attr_reader :items

    def initialize(items)
      @items = Array(items)
    end

    def filter(opts = {})
      result = if opts[:selected]
                 items.select { |pagelet| opts[:selected].include?(pagelet.key.to_s) }
               else
                 items.select do |pagelet|
                   pagelet.profiles.empty? ? true : pagelet.profiles.any? { |profile| profile.default? }
                 end
               end
      result.uniq
    end
  end
end
