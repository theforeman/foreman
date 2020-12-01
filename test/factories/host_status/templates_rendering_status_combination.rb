FactoryBot.define do
  factory :templates_rendering_status_combination, class: "HostStatus::TemplatesRenderingStatusCombination" do
    association :host, factory: [:host, :managed]
    association :template, factory: :provisioning_template
    host_status { host.get_status('HostStatus::TemplatesRenderingStatus') }
    status { HostStatus::TemplatesRenderingStatus::OK }
  end
end
