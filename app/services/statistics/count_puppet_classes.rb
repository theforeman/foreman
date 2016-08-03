module Statistics
  class CountPuppetClasses < Base
    def initialize(options = {})
      super(options)
      raise(ArgumentError, 'Must provide an :id or :count_by option') if id.empty?
    end

    def calculate
      Puppetclass.authorized(:view_puppetclasses).map do |pc|
        count = pc.hosts_count
        next if count.zero?
        {
          :label => pc.to_label,
          :data => count
        }
      end.compact
    end
  end
end
