class Log < ActiveRecord::Base
  belongs_to :message
  belongs_to :source
  belongs_to :report
  validates_presence_of :message_id, :source_id, :report_id, :level_id

  LEVELS = [:debug, :info, :notice, :warning, :err, :alert, :emerg, :crit]

  def to_s
    "#{source} #{message}"
  end

  def level= l
    write_attribute(:level_id, LEVELS.index(l))
  end

  def level
    LEVELS[level_id]
  end

  def as_json(options={})
    {:log => {:messages => message, :sources => source}}
  end

end
