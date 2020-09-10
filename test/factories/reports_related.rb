FactoryBot.define do
  factory :report do
    host
    reported_at { Time.now.utc }
    status { 0 }
    metrics { YAML.load("--- \n  time: \n    schedule: 0.00083\n    service: 0.149739\n    mailalias: 0.000283\n    cron: 0.000419\n    config_retrieval: 16.3637869358063\n    package: 0.003989\n    filebucket: 0.000171\n    file: 0.007025\n    exec: 0.000299\n  resources: \n    total: 33\n  changes: {}\n  events: \n    total: 0") }
    type { 'ConfigReport' }
  end

  factory :config_report, :parent => :report, :class => 'ConfigReport'

  trait :old_report do
    after(:build) do |report|
      report.created_at  = 2.weeks.ago
      report.reported_at = 2.weeks.ago
    end
  end

  trait :with_logs do
    transient do
      log_count { 5 }
    end
    after(:create) do |report, evaluator|
      evaluator.log_count.times do
        FactoryBot.create(:log, :report => report)
      end
    end
  end

  trait :adrift do
    after(:build) do |report|
      report.created_at  = 20.minutes.ago
      report.reported_at = 5.minutes.ago
    end
  end

  factory :log do
    report
    level_id { 1 }
    after(:build) do |log|
      log.message = FactoryBot.create(:message)
      log.source = FactoryBot.create(:source)
    end
  end

  factory :message do
    sequence(:value) { |n| "message#{n}" }
    sequence(:digest) { |n| Digest::SHA1.hexdigest("message#{n}") }
  end

  factory :source do
    sequence(:value) { |n| "source#{n}" }
    sequence(:digest) { |n| Digest::SHA1.hexdigest("source#{n}") }
  end
end
