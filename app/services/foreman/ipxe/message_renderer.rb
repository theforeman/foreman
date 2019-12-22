# frozen_string_literal: true

module Foreman
  module Ipxe
    class MessageRenderer
      attr_accessor :message

      def initialize(message:)
        @message = message
      end

      def to_s
        <<~MESSAGE
          #!ipxe
          echo #{message}
          shell
        MESSAGE
      end
    end
  end
end
