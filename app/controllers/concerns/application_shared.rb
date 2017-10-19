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

      if api_request? # API request
        if user.admin? && !params.has_key?("#{taxonomy}_id") # admin always uses any context, they can limit the scope with explicit parameters such as organization_id(s)
          determined_taxonomy = nil
        elsif params.has_key?("#{taxonomy}_id") # admin and non-admin who specified explicit context
          determined_taxonomy = available.where(:id => params["#{taxonomy}_id"]).first

          # in case admin asked for taxonomy that does not exist or is not accessible, we reply with 404
          if determined_taxonomy.nil?
            not_found _("%{taxonomy} with id %{id} not found") % { :taxonomy => taxonomy.capitalize, :id => params["#{taxonomy}_id"] }
            return false
          end
        elsif request.session["#{taxonomy}_id"].present? # non-admin who didn't not specify explicit context
          determined_taxonomy = find_session_taxonomy(taxonomy, user)
        else # non-admin user who didn't specify explicit context and does not have anything in session
          determined_taxonomy = find_default_taxonomy(user, taxonomy)
        end
      else # UI request
        if request.session["#{taxonomy}_id"].present?
          determined_taxonomy = find_session_taxonomy(taxonomy, user)
        elsif !user.admin? && available.count == 1
          determined_taxonomy = available.first
        end
      end

      store_taxonomy(taxonomy, determined_taxonomy) if determined_taxonomy.present?
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
    available = user.send("my_#{taxonomy.pluralize}")

    if default_taxonomy.present? && available.include?(default_taxonomy)
      default_taxonomy
    elsif available.count == 1
      available.first
    else
      # no available default taxonomy and user is either admin or user with more taxonomies, nil represents "Any Context"
      nil
    end
  end

  def find_session_taxonomy(taxonomy, user)
    available = user.send("my_#{taxonomy.pluralize}")
    determined_taxonomy = available.where(:id => request.session["#{taxonomy}_id"]).first
    # warn user if taxonomy stored in session does not exist and delete it from session (probably taxonomy has been deleted meanwhile)
    if determined_taxonomy.nil?
      warning _("%s you had selected as your context has been deleted") % taxonomy.capitalize unless api_request?
      request.session["#{taxonomy}_id"] = nil
      determined_taxonomy = find_default_taxonomy(user, taxonomy)
    end
    determined_taxonomy
  end
end
