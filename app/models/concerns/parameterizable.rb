module Parameterizable
  def self.parameterize(string)
    string.gsub(/[\/.>]/, '-').gsub(/[<!*'();:@&=+$,?%#\[\]]/, '').chomp('-')
  end

  module ById
    extend ActiveSupport::Concern

    included do
      def to_param
        id.to_s
      end

      def self.from_param(id)
        find_by_id(id.to_i)
      end
    end
  end

  module ByIdName
    extend ActiveSupport::Concern

    included do
      def to_param
        # remove characters unsafe for urls, keep unicode ones
        Parameterizable.parameterize("#{id}-#{name}")
      end

      def self.from_param(id_name)
        find_by_id(id_name.to_i) if id_name =~ /\A\d+-/
      end
    end
  end

  module ByName
    extend ActiveSupport::Concern

    # Warning:
    # This parameterization is allowed only for resources that have url-safe names!
    # Check the name format validator before use.

    included do
      def to_param
        name
      end

      def self.from_param(name)
        find_by_name(name.to_s)
      end
    end
  end
end
