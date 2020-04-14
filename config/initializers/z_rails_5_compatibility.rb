module Foreman
  module Rails5
    module RablTemplateHandlerExt
      def call(template, source = nil)
        source ||= template.source
        super(template, source)
      end
    end

    module CollectionLoaderAssocRead
      def read_association(_preloader, record)
        record.public_send(association_name)
      end
    end
  end
end

ActionView::Template::Handlers::Rabl.singleton_class.prepend Foreman::Rails5::RablTemplateHandlerExt
if Rails.version.start_with?('5.2')
  CollectionLoader.prepend Foreman::Rails5::CollectionLoaderAssocRead
end
