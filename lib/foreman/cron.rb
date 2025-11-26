require 'logger'
require 'rake'

module Foreman
  module Cron
    SUPPORTED_CADENCES = [:hourly, :daily, :weekly, :monthly].freeze

    class << self
      def register(cadence, task_name)
        cadence = cadence.to_sym

        unless SUPPORTED_CADENCES.include?(cadence)
          logger.warn(
            "Foreman::Cron[#{cadence}]: unknown cadence when registering #{task_name}, ignoring"
          )
          return
        end

        cadence_tasks = tasks_for(cadence)
        cadence_tasks << task_name unless cadence_tasks.include?(task_name)
      end

      def run(cadence)
        cadence = cadence.to_sym

        cadence_tasks = tasks_for(cadence)
        if cadence_tasks.empty?
          logger.debug("Foreman::Cron[#{cadence}]: no tasks configured for this cadence")
          return false
        end

        logger.info("Foreman::Cron[#{cadence}]: running #{cadence_tasks.size} task(s)")

        failed_tasks = 0

        cadence_tasks.each do |task_name|
          failed_tasks += 1 unless run_task(cadence, task_name)
        end

        failed_tasks.positive?
      end

      private

      def tasks
        @tasks ||= Hash.new { |h, k| h[k] = [] }
      end

      def tasks_for(cadence)
        tasks[cadence.to_sym]
      end

      def run_task(cadence, task_name)
        logger.info("Foreman::Cron[#{cadence}]: starting #{task_name}")

        task = Rake::Task[task_name]
        task.reenable
        task.invoke

        logger.info("Foreman::Cron[#{cadence}]: finished #{task_name}")
        true
      rescue StandardError => e
        logger.error(
          "Foreman::Cron[#{cadence}]: #{task_name} failed: #{e.class}: #{e.message}"
        )
        logger.debug(e.backtrace.join("\n")) if e.backtrace
        false
      end

      def logger
        @logger ||= Logger.new($stdout)
      end
    end
  end
end
