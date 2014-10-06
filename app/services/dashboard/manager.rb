module Dashboard
  module Manager

    class << self
      def map
        @widgets ||= []
        mapper = Mapper.new(@widgets)
        if block_given?
          yield mapper
        else
          mapper
        end
      end

      def widgets
        # force menu reload in development when auto loading modified files
        @widgets ||= Dashboard::Loader.load
      end
    end

    class Mapper
      attr_reader :widgets

      def initialize(widgets)
        @widgets = widgets
      end

      # Adds an widget at the end of the list. Available options:
      # * before, after: specify where the widget should be inserted (eg. :after => :activity)
      def push(obj, options = {})

        target_root = @widgets.first

        # menu widget position
        if options[:first]
          @widgets.unshift(obj)
        elsif (before = options[:before]) && exists?(before)
          @widgets.insert( position_of(before), obj)
        elsif (after = options[:after]) && exists?(after)
          @widgets.insert( position_of(after) + 1, obj)
        else
          @widgets.push(obj)
        end
      end

      def widget(id, options = {})
        push(Widget.new(id, options), options)
      end

      # Removes a menu widget
      def delete(name)
        if found = self.find(name)
          @widgets.remove!(found)
        end
      end

      # Checks if a menu widget exists
      def exists?(name)
        @widgets.any? {|widget| widget.name == name}
      end

      def find(name)
        @widgets.find {|widget| widget.name == name}
      end

      def position_of(name)
        @widgets.each do |widget|
          if widget.name == name
            return widget.position
          end
        end
      end

    end
  end
end
