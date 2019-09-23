module Hostext
  module FactData
    extend ActiveSupport::Concern

    def set_reported_data(parser)
      facet = reported_data_facet
      set_reported_attribute(facet, :boot_time, :boot_timestamp, parser) { |value| Time.at value }
      set_reported_attribute(facet, :virtual, :virtual, parser)
      set_reported_attribute(facet, :ram, :ram, parser)
      set_reported_attribute(facet, :sockets, :sockets, parser)
      set_reported_attribute(facet, :cores, :cores, parser)
      facet.save if facet.changed?
    end

    def cores
      get_reported_attribute :cores
    end

    def virtual
      get_reported_attribute :virtual
    end

    def sockets
      get_reported_attribute :sockets
    end

    def ram
      get_reported_attribute :ram
    end

    def uptime_seconds
      get_reported_attribute(:boot_time) do |value|
        value.nil? ? nil : Time.zone.now.to_i - value.to_i
      end
    end

    def reported_data_facet
      self.reported_data || self.build_reported_data
    end

    private

    def get_reported_attribute(attr_name)
      value = self&.reported_data&.public_send(attr_name)
      return value unless block_given?
      yield value
    end

    def set_reported_attribute(facet, attr_name, method_name, parser)
      value = parser.public_send(method_name)
      return if value.nil?
      formatted_value = if block_given?
                          yield value
                        else
                          value
                        end

      facet.public_send("#{attr_name}=", formatted_value) if self.persisted?
    end
  end
end
