class Notice < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table =>'user_notices'

  TYPES = %w{message warning}
  before_validation :set_default_notice_level
  validates_inclusion_of :level, :in => TYPES

  validates_presence_of :content
  before_save :add_to_all_users

  def to_s
    "#{global? ? "global" : "individual"} #{content}"
  end

  def destroy_notice
    if global
      destroy
    else
      users.delete(User.current)
      destroy unless users.any?
    end
  end
  private

  def add_to_all_users
    self.users = User.all
  end

  def set_default_notice_level
    self.level ||= TYPES.first
  end
end
