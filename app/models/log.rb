class Log < ApplicationRecord
  belongs_to :message
  belongs_to :source
  belongs_to :report

  validates :message_id, :source_id, :report_id, :level_id, :presence => true

  default_scope -> { order('logs.id') }

  LEVELS = [:debug, :info, :notice, :warning, :err, :alert, :emerg, :crit]

  def to_s
    "#{source} #{message}"
  end

  def level=(l)
    self[:level_id] = LEVELS.index(l)
  end

  def level
    LEVELS[level_id]
  end
end
