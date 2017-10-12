module ApplicationShared
  extend ActiveSupport::Concern

  include Foreman::Controller::MigrationChecker
  include Foreman::Controller::Authentication
  include Foreman::Controller::Session
  include Foreman::Controller::TopbarSweeper
  include Foreman::ThreadSession::Cleaner
  include FindCommon

  def set_timezone
    default_timezone = Time.zone
    client_timezone  = User.current.try(:timezone) || cookies[:timezone]
    Time.zone        = client_timezone if client_timezone.present?
    yield
  ensure
    # Reset timezone for the next thread
    Time.zone = default_timezone
  end

  def current_permission
    [action_permission, controller_permission].join('_')
  end

  def set_taxonomy
    user = User.current
    return if user.nil?

    ['location', 'organization'].each do |taxonomy|
      next unless Taxonomy.enabled?(taxonomy.to_sym)

      available = user.send("my_#{taxonomy.pluralize}")
      determined_taxonomy = nil

      # this keeps "any context" for admins unless they ask for specific context via parameters
      if api_request? && user.admin?
        if params["#{taxonomy}_id"].present?
          determined_taxonomy = available.where(:id => params["#{taxonomy}_id"]).first

          # in case user asked for taxonomy that does not exist or is not accessible, we reply with 404
          if determined_taxonomy.nil?
            not_found _("%{taxonomy} with id %{id} not found") % { :taxonomy => taxonomy.capitalize, :id => params["#{taxonomy}_id"] }
            return false
          end
        else
          determined_taxonomy = nil
        end
      # if there was a session set, try to load the taxonomy from there
      elsif request.session["#{taxonomy}_id"].present?
        determined_taxonomy = available.where(:id => request.session["#{taxonomy}_id"]).first
        # warn user if taxonomy stored in session does not exist and delete it from session (probably taxonomy has been deleted meanwhile)
        if determined_taxonomy.nil?
          warning _("#{taxonomy.capitalize} you had selected as your context has been deleted") unless api_request?
          request.session["#{taxonomy}_id"] = nil
          determined_taxonomy = find_default_taxonomy(user, taxonomy)
        end
      # no session, non-admin API request uses default taxonomy
      elsif api_request?
        determined_taxonomy = find_default_taxonomy(user, taxonomy)
      elsif !user.admin? && available.count == 1
        determined_taxonomy = available.first
      end

      if determined_taxonomy.present?
        store_taxonomy(taxonomy, determined_taxonomy)
      end
    end
  end

  def store_taxonomy(taxonomy, determined_taxonomy)
    taxonomy.classify.constantize.send 'current=', determined_taxonomy
    request.session["#{taxonomy}_id"] = determined_taxonomy.id
  end

  def store_default_taxonomies(user)
    ['location', 'organization'].each do |taxonomy|
      default_taxonomy = find_default_taxonomy(user, taxonomy)
      store_taxonomy(taxonomy, default_taxonomy) if default_taxonomy.present?
    end
  end

  # we want to be explicit to keep this readable
  # rubocop:disable Style/EmptyElse
  def find_default_taxonomy(user, taxonomy)
    default_taxonomy = user.send "default_#{taxonomy}"

    if default_taxonomy.present?
      default_taxonomy
    else
      # no default taxonomy and user is either admin or user with more taxonomies, nil represents "Any Context"
      nil
    end
  end
end
