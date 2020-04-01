module Foreman
  module Rails5
    module RablTemplateHandlerExt
      def call(template, source = nil)
        source ||= template.source
        super(template, source)
      end
    end
  end
end

ActionView::Template::Handlers::Rabl.singleton_class.prepend Foreman::Rails5::RablTemplateHandlerExt
