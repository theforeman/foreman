class ApplicationJob < ActiveJob::Base
  def humanized_name
    self.class.name
  end
end
