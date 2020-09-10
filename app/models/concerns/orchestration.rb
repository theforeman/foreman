require_dependency "proxy_api"
require_dependency 'orchestration/queue'

module Orchestration
  extend ActiveSupport::Concern
  include Orchestration::ProgressReport

  included do
    attr_reader :old

    # save handles both creation and update of hosts
    around_save :around_save_orchestration
    after_commit :post_commit
    after_destroy :on_destroy
  end

  module ClassMethods
    def rebuild_methods
      @rebuild_methods || {}
    end

    def rebuild_methods=(methods)
      @rebuild_methods = methods || {}
    end

    def rebuild_methods_for(only = nil)
      if only.present?
        (@rebuild_methods || {}).select { |k, v| only.include?(v) }
      else
        @rebuild_methods || {}
      end
    end

    def register_rebuild(method, pretty_name)
      @rebuild_methods ||= {}
      fail "Method :#{method} is already registered, choose different name for your method" if @rebuild_methods[method]
      @rebuild_methods.merge!(method => pretty_name)
    end
  end

  protected

  def around_save_orchestration
    process :queue

    begin
      yield
    rescue ActiveRecord::ActiveRecordError => e
      Foreman::Logging.exception "Rolling back due to exception during save", e
      fail_queue queue
      raise e
    end
  end

  def post_commit
    process :post_queue
  end

  def on_destroy
    errors.empty? ? process(:queue) : rollback
  end

  def rollback
    raise ActiveRecord::Rollback
  end

  # Log and add error to model
  def failure(message, exception = nil, dest = :base)
    log_failure(message, exception)
    errors.add(dest, message)
    false
  end

  def log_failure(message, exception)
    return Foreman::Logging.exception(message, exception) if exception.present?
    logger.warn(message)
  end

  public

  # we override this method in order to include checking the
  # after validation callbacks status, as rails by default does
  # not care about their return status.
  def valid?(context = nil)
    setup_clone if SETTINGS[:unattended]
    super
    orchestration_errors?
  end

  def queue
    @queue ||= Orchestration::Queue.new(self.class.name + ' Main')
  end

  def post_queue
    @post_queue ||= Orchestration::Queue.new(self.class.name + ' Post')
  end

  def record_conflicts
    @record_conflicts ||= []
  end

  def skip_orchestration!
    @skip_orchestration = true
  end

  def enable_orchestration!
    @skip_orchestration = false
  end

  def skip_orchestration?
    return true if skip_orchestration_for_testing?
    !!@skip_orchestration
  end

  def skip_orchestration_for_testing?
    # The orchestration should be disabled in tests in order to avoid side effects.
    # If a test needs to enable orchestration, it should be done explicitly by stubbing
    # this method.
    Rails.env.test?
  end

  def without_orchestration(&block)
    skip_orchestration! if SETTINGS[:unattended]
    yield
  ensure
    enable_orchestration! if SETTINGS[:unattended]
  end

  private

  # Handles the actual queue
  # takes care for running the tasks in order
  # if any of them fail, it rollbacks all completed tasks
  # in order not to keep any left overs in our proxies.
  def process(queue_name)
    processed = 0
    return true if skip_orchestration?

    # queue is empty - nothing to do.
    q = send(queue_name)
    return if q.empty?

    # process all pending tasks
    q.pending.each do |task|
      # if we have failures, we don't want to process any more tasks
      break unless q.failed.empty?

      task.status = "running"
      update_cache
      logger.debug("Processing task '#{task.name}' from '#{q.name}'")
      begin
        task.status = execute({:action => task.action}) ? "completed" : "failed"
        processed += 1
      rescue Net::Conflict => e
        task.status = "conflict"
        add_conflict(e)
        failure e.message, nil, :conflict
      rescue => e
        task.status = "failed"
        failure _("%{task} task failed with the following error: %{e}") % { :task => task.name, :e => e }, e
      end
    end

    update_cache
    # if we have no failures - we are done
    return true if q.failed.empty? && q.pending.empty? && q.conflict.empty? && orchestration_errors?

    logger.warn "Rolling back due to a problem: #{q.failed + q.conflict}"
    fail_queue(q)

    rollback
  ensure
    unless q.nil?
      if processed > 0
        logger.info("Processed #{processed} tasks from queue '#{q.name}', completed #{q.completed.count}/#{q.all.count}") unless q.empty?
        # rubocop:disable Rails/FindEach
        q.all.each do |task|
          msg = "Task '#{task.name}' *#{task.status}*"
          if task.status?(:completed) || task.status?(:pending)
            logger.debug msg
          else
            logger.error msg
          end
        end
        # rubocop:enable Rails/FindEach
      end
    end
  end

  def fail_queue(q)
    q.pending.each { |task| task.status = "canceled" }

    # handle errors
    # we try to undo all completed operations and trigger a DB rollback
    (q.completed + q.running).sort.reverse_each do |task|
      task.status = "rollbacked"
      update_cache
      execute({:action => task.action, :rollback => true})
    rescue => e
      # if the operation failed, we can just report upon it
      failure _("Failed to perform rollback on %{task} - %{e}") % { :task => task.name, :e => e }, e
    end
  end

  def add_conflict(e)
    @record_conflicts << e
  end

  def execute(opts = {})
    obj, met, param = opts[:action]
    rollback = opts[:rollback] || false
    # at the moment, rollback are expected to replace set with del in the method name
    if rollback
      met = met.to_s
      case met
      when /set/
        met.gsub!("set", "del")
      when /del/
        met.gsub!("del", "set")
      else
        raise "Dont know how to rollback #{met}"
      end
      met = met.to_sym
    end
    if obj.respond_to?(met, true)
      param.nil? || (return obj.send(met, param))
      obj.send(met)
    else
      failure _("invalid method %s") % met
      raise ::Foreman::Exception.new(N_("invalid method %s"), met)
    end
  end

  def orchestration_errors?
    overwrite? ? errors.are_all_conflicts? : errors.empty?
  end

  def update_cache
    Rails.cache.write(progress_report_id, (queue.all + post_queue.all).to_json, :expires_in => 5.minutes)
  end

  def attr_equivalent?(old, new)
    (old.blank? && new.blank?) || (old == new)
  end
end
