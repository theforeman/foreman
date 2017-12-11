module UINotifications
  class ActionsBuilder
    def initialize
      @actions = []
    end

    def push(url, title, external)
      @actions << [url, title, external]
      self
    end

    def build
      result = {:links => []}
      @actions.each do |url, title, external|
        result[:links] << {
          :href => url,
          :title => title,
          :external => external
        }
      end
      result
    end
  end
end
