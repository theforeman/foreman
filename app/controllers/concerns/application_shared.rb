module ApplicationShared
  extend ActiveSupport::Concern

  include Foreman::Controller::MigrationChecker
  include Foreman::Controller::Authentication
  include Foreman::Controller::Session
  include Foreman::Controller::TopbarSweeper
  include Foreman::Controller::Timezone
  include Foreman::ThreadSession::Cleaner
  include FindCommon

  def model_of_controller
    @model_of_controller ||= controller_path.singularize.camelize.gsub('/', '::').constantize
  end

  def current_permission
    [action_permission, controller_permission].join('_')
  end

  def set_current_user(user)
    super
    set_taxonomy
    user.present?
  end

  def set_taxonomy
    TopbarSweeper.expire_cache
    user = User.current
    return if user.nil?

    ['location', 'organization'].each do |taxonomy|
      available = user.send("my_#{taxonomy.pluralize}")
      determined_taxonomy = nil

      if api_request? # API request
        if params.has_key?("#{taxonomy}_id") # admin and non-admin who specified context explicitly
          if params["#{taxonomy}_id"].blank? # the key is present and explicitly set to nil which indicates "any" context
            determined_taxonomy = nil
          else
            determined_taxonomy = available.where(:id => params["#{taxonomy}_id"]).first

            # in case user asked for taxonomy that does not exist or is not accessible, we reply with 404
            if determined_taxonomy.nil?
              not_found _("%{taxonomy} with id %{id} not found") % { :taxonomy => taxonomy.capitalize, :id => params["#{taxonomy}_id"] }
              return false
            end
          end
        elsif session.has_key?("#{taxonomy}_id") # session with taxonomy explicitly set to id or nil (any context)
          if session["#{taxonomy}_id"].present?
            determined_taxonomy = find_session_taxonomy(taxonomy, user) # specific id
          else
            determined_taxonomy = nil # explicitly set any context
          end
        else
          determined_taxonomy = nil
        end
      else # UI request
        if session["#{taxonomy}_id"].present?
          determined_taxonomy = find_session_taxonomy(taxonomy, user)
        elsif !user.admin? && available.count == 1
          determined_taxonomy = available.first
        end
      end

      set_current_taxonomy(taxonomy, determined_taxonomy)
      store_taxonomy(taxonomy, determined_taxonomy) unless api_request?
    end
  end

  # determined_taxonomy can be nil, which means any context
  def store_taxonomy(taxonomy, determined_taxonomy)
    # session can't store nil, so we use empty string to represent any context
    session["#{taxonomy}_id"] = determined_taxonomy.try(:id) || ''
  end

  def set_current_taxonomy(taxonomy, determined_taxonomy)
    taxonomy.classify.constantize.send 'current=', determined_taxonomy
  end

  def store_default_taxonomy(user, taxonomy)
    default_taxonomy = find_default_taxonomy(user, taxonomy)
    set_current_taxonomy(taxonomy, default_taxonomy)
    store_taxonomy(taxonomy, default_taxonomy)
  end

  # we want to be explicit to keep this readable
  def find_default_taxonomy(user, taxonomy)
    default_taxonomy = user.send "default_#{taxonomy}"
    available = user.send("my_#{taxonomy.pluralize}")

    if default_taxonomy.present? && available.include?(default_taxonomy)
      default_taxonomy
    elsif available.count == 1 && !user.admin?
      available.first
    # rubocop:disable Style/EmptyElse
    else
      # no available default taxonomy and user is either admin or user with more taxonomies, nil represents "Any Context"
      nil
    end
    # rubocop:enable Style/EmptyElse
  end

  def find_session_taxonomy(taxonomy, user)
    available = user.send("my_#{taxonomy.pluralize}")
    determined_taxonomy = available.where(:id => session["#{taxonomy}_id"]).first
    # warn user if taxonomy stored in session does not exist and delete it from session (probably taxonomy has been deleted meanwhile)
    if determined_taxonomy.nil?
      if api_request?
        not_found _("%{taxonomy} stored in session with id %{id} not found") % { :taxonomy => taxonomy.capitalize, :id => params["#{taxonomy}_id"] }
        return false
      else
        warning _("%s you had selected as your context has been deleted") % taxonomy.capitalize
      end
      session.delete("#{taxonomy}_id")
      determined_taxonomy = find_default_taxonomy(user, taxonomy)
    end
    determined_taxonomy
  end
end
