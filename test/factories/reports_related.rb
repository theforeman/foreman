FactoryGirl.define do
  factory :report do
    host
    sequence(:reported_at) { |n| n.minutes.ago }
    status 0
    metrics YAML.load("--- \n  time: \n    schedule: 0.00083\n    service: 0.149739\n    mailalias: 0.000283\n    cron: 0.000419\n    config_retrieval: 16.3637869358063\n    package: 0.003989\n    filebucket: 0.000171\n    file: 0.007025\n    exec: 0.000299\n  resources: \n    total: 33\n  changes: {}\n  events: \n    total: 0")
  end
end
