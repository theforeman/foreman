module UINotifications
  # interpolates blueprint links for notifications
  class URLResolver
    # needed in order to resolve rails urls for notifications
    include Rails.application.routes.url_helpers
    def initialize(subject, actions = nil)
      @subject = subject
      @raw_actions = actions
    end

    def actions
      return if raw_actions.try(:[], :links).nil?
      links = raw_actions[:links].map do |link|
        validate_title link
        if link.has_key? :href
          link
        elsif link.has_key? :path_method
          validate_link(link)
          parse_link(link[:path_method], link[:title])
        end
      end
      {links: links}
    end

    private

    attr_reader :subject, :raw_actions

    def parse_link(path_method, title)
      {
        href: path_for(path_method),
        title: StringParser.new(title, {subject: subject}).to_s,
      }
    end

    def validate_title(link)
      if link[:title].blank?
        raise(Foreman::Exception, "Invalid link, must contain :title")
      end
    end

    def validate_link(link)
      path_method = link[:path_method]
      unless path_method.to_s =~ /_path$/
        raise(Foreman::Exception, "Invalid path_method #{path_method}, must end with _path")
      end
    end

    def path_for(path_method)
      if collection_path?(path_method)
        public_send(path_method)
      else
        public_send(path_method, subject)
      end
    end

    def collection_path?(path)
      path.to_s.sub(/_path$/, '').ends_with?('s')
    end
  end
end
