class UpgradeTask < ApplicationRecord
  validates :name, :presence => true, :uniqueness => true
  validates :task_name, :presence => true

  before_validation :ensure_name, on: :create

  scope :needing_run, lambda {
    where(:last_run_time => nil).or(where(:always_run => true)).order(ordering: :asc, created_at: :asc)
  }

  def mark_as_ran!
    update!(:last_run_time => Time.now)
  end

  def self.define_tasks(subject)
    existing = UpgradeTask.where(:subject => subject)
    seeded_tasks = yield

    # delete unknown tasks
    existing_names = seeded_tasks.pluck(:name)
    existing.where.not(:name => existing_names).destroy_all

    seeded_tasks.each do |seed_task|
      if (existing_task = existing.find_by(:name => seed_task[:name]))
        existing_task.update!(seed_task)
      else
        seed_task[:subject] = subject
        create!(seed_task)
      end
    end
  end

  def ensure_name
    self.task_name ||= name
  end
end
