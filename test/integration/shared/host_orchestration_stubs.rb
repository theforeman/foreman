module HostOrchestrationStubs
  extend ActiveSupport::Concern

  def click_on_submit
    click_button('Submit')
    wait_for_orchestration_requests # host-progress bar should disappear
    wait_for_ajax # wait for runtime/nics/etc.. ajax requests in Host#show
    assert page.has_link?('Edit')
  end

  def wait_for_orchestration_requests
    has_no_selector?("#host-progress",
      :visible => :all,
      :wait => 2 * Capybara.default_max_wait_time)
  end
end
