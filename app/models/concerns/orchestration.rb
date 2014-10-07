require "proxy_api"
require 'orchestration/queue'

module Orchestration
  extend ActiveSupport::Concern

  included do
    attr_reader :old

    # save handles both creation and update of hosts
    before_save :on_save
    after_commit :post_commit
    after_destroy :on_destroy
  end

  protected
  def on_save
    process :queue
  end

  def post_commit
    process :post_queue
  end

  def on_destroy
    errors.empty? ? process(:queue) : false
  end

  def rollback
    raise ActiveRecord::Rollback
  end

  # log and add to errors
  def failure(msg, backtrace = nil, dest = :base)
    logger.warn(backtrace ? msg + backtrace.join("\n") : msg)
    errors.add dest, msg
    false
  end

  public

  # we override this method in order to include checking the
  # after validation callbacks status, as rails by default does
  # not care about their return status.
  def valid?(context = nil)
    setup_clone
    super
    orchestration_errors?
  end

  def queue
    @queue ||= Orchestration::Queue.new
  end

  def post_queue
    @post_queue ||= Orchestration::Queue.new
  end

  def record_conflicts
    @record_conflicts ||= []
  end

  private

  # Handles the actual queue
  # takes care for running the tasks in order
  # if any of them fail, it rollbacks all completed tasks
  # in order not to keep any left overs in our proxies.
  def process(queue_name)
    return true if Rails.env == "test"

    # queue is empty - nothing to do.
    q = send(queue_name)
    return if q.empty?

    # process all pending tasks
    q.pending.each do |task|
      # if we have failures, we don't want to process any more tasks
      break unless q.failed.empty?

      task.status = "running"

      update_cache
      begin
        task.status = execute({:action => task.action}) ? "completed" : "failed"

      rescue Net::Conflict => e
        task.status = "conflict"
        record_conflicts << e
        failure e.message, nil, :conflict
      rescue => e
        task.status = "failed"
        failure _("%{task} task failed with the following error: %{e}") % { :task => task.name, :e => e }, e.backtrace
      end
    end

    update_cache
    # if we have no failures - we are done
    return true if q.failed.empty? and q.pending.empty? and q.conflict.empty? and orchestration_errors?

    logger.warn "Rolling back due to a problem: #{q.failed + q.conflict}"
    q.pending.each{ |task| task.status = "canceled" }

    # handle errors
    # we try to undo all completed operations and trigger a DB rollback
    (q.completed + q.running).sort.reverse_each do |task|
      begin
        task.status = "rollbacked"
        update_cache
        execute({:action => task.action, :rollback => true})
      rescue => e
        # if the operation failed, we can just report upon it
        failure _("Failed to perform rollback on %{task} - %{e}") % { :task => task.name, :e => e }
      end
    end

    rollback
  end

  def execute(opts = {})
    obj, met = opts[:action]
    rollback = opts[:rollback] || false
    # at the moment, rollback are expected to replace set with del in the method name
    if rollback
      met = met.to_s
      case met
      when /set/
        met.gsub!("set","del")
      when /del/
        met.gsub!("del","set")
      else
        raise "Dont know how to rollback #{met}"
      end
      met = met.to_sym
    end
    if obj.respond_to?(met,true)
      return obj.send(met)
    else
      failure _("invalid method %s") % met
      raise ::Foreman::Exception.new(N_("invalid method %s"), met)
    end
  end

  # we keep the before update host object in order to compare changes
  def setup_clone
    return if new_record?
    @old = dup
    for key in (changed_attributes.keys - ["updated_at"])
      @old.send "#{key}=", changed_attributes[key]
      # At this point the old cached bindings may still be present so we force an AR association reload
      # This logic may not work or be required if we switch to Rails 3
      if (match = key.match(/\A(.*)_id\Z/))
        name = match[1].to_sym
        next if name == :owner # This does not work for the owner association even from the console
        self.send(name, true) if (send(name) and send(name).id != @attributes[key])
        old.send(name, true)  if (old.send(name) and old.send(name).id != old.attributes[key])
      end
    end
  end

  def orchestration_errors?
    overwrite? ? errors.are_all_conflicts? : errors.empty?
  end

  def update_cache
    Rails.cache.write(progress_report_id, (queue.all + post_queue.all).to_json, :expires_in => 5.minutes)
  end

end
