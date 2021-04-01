class HostStatusPresenter
  class Collection < Array
    def search_for(*search_options)
      self
    end
  end

  def self.all
    array = HostStatus.status_registry
                      .select { |s| s.const_defined?('LABELS') }
                      .map(&:presenter)
    Collection.new(array)
  end

  def initialize(status_class)
    @status_class = status_class
  end

  attr_reader :status_class
  delegate :status_name, to: :status_class
  alias_method :name, :status_name

  def description
    status_class.try(:description)
  end

  def global_statuses
    @global_statuses ||= all_statuses.index_with do |status|
      if error_statuses.include?(status)
        HostStatus::Global::ERROR
      elsif warn_statuses.include?(status)
        HostStatus::Global::WARN
      elsif ok_statuses.include?(status)
        HostStatus::Global::OK
      end
    end
  end

  [:ok, :warn, :error].each do |status_name|
    define_method :"#{status_name}_total_query" do
      query = total_queries.select { |k, v| send("#{status_name}_statuses").include?(k) }.values.compact.join(' OR ')
      return if query.empty?

      query
    end

    define_method :"#{status_name}_owned_query" do
      query = send("#{status_name}_total_query")
      return if query.empty?

      "owner = current_user AND (#{query})"
    end

    define_method :"#{status_name}_total_path" do
      query = send("#{status_name}_total_query")
      return if query.empty?

      Rails.application.routes.url_helpers.hosts_path(search: query)
    end

    define_method :"#{status_name}_owned_path" do
      query = send("#{status_name}_owned_query")
      return if query.empty?

      Rails.application.routes.url_helpers.hosts_path(search: query)
    end
  end

  def total
    @total ||= begin
      data = total_data
      all_statuses.index_with { |status| data.fetch(status, 0) }
    end
  end

  def owned
    @owned ||= begin
      data = owned_data

      all_statuses.index_with { |status| data.fetch(status, 0) }
    end
  end

  def all_statuses
    ok_statuses | warn_statuses | error_statuses | total_data.keys
  end

  def total_paths
    total_queries.transform_values do |query|
      Rails.application.routes.url_helpers.hosts_path(search: query)
    end
  end

  def owned_paths
    owned_queries.transform_values do |query|
      Rails.application.routes.url_helpers.hosts_path(search: query)
    end
  end

  def labels
    Object.const_get("#{status_class}::LABELS", false)
  rescue NameError
    {}
  end

  private

  def total_data
    status_class.group(:status).count
  end

  def owned_data
    status_class.where(host_id: Host::Managed.search_for('owner = current_user').select(:id)).group(:status).count
  end

  def total_queries
    Object.const_get("#{status_class}::SEARCH", false)
  rescue NameError
    {}
  end

  def owned_queries
    total_queries.transform_values { |v| "owner = current_user AND (#{v})" }
  end

  def ok_statuses
    Object.const_get("#{status_class}::OK_STATUSES", false)
  rescue NameError
    []
  end

  def warn_statuses
    Object.const_get("#{status_class}::WARN_STATUSES", false)
  rescue NameError
    []
  end

  def error_statuses
    Object.const_get("#{status_class}::ERROR_STATUSES", false)
  rescue NameError
    []
  end
end
