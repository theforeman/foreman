module Parameterizable
  def self.parameterize(string)
    string.gsub(/[\/.>]/, '-').gsub(/[<!*'();:@&=+$,?%#\[\]]/, '').chomp('-')
  end

  module Finder
    def find(*args)
      if args.size == 1 && (args.first.is_a?(String) || args.first.is_a?(Numeric))
        from_param(args.first)
      else
        super
      end
    end
  end

  module ById
    extend ActiveSupport::Concern

    included do
      extend ::Parameterizable::Finder
      def to_param
        id.to_s
      end

      def self.from_param(id)
        self.where(:id => id.to_i).first
      end
    end
  end

  module ByIdName
    extend ActiveSupport::Concern

    included do
      extend ::Parameterizable::Finder
      def to_param
        # remove characters unsafe for urls, keep unicode ones
        Parameterizable.parameterize("#{id}-#{name}")
      end

      def self.from_param(id_name)
        self.where(:id => id_name.to_i).first
      end
    end
  end

  module ByName
    extend ActiveSupport::Concern

    # Warning:
    # This parameterization is allowed only for resources that have url-safe names!
    # Check the name format validator before use.

    included do
      extend ::Parameterizable::Finder
      def to_param
        name
      end

      def self.from_param(name)
        if name.is_a?(Numeric)
          self.where(:id => name).first
        else
          self.where(:name => name).first
        end
      end
    end
  end
end
