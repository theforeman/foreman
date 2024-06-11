class BuildTimeoutJob < ApplicationJob
  def preform(cancellation)
    cancellation.call
  end

  def humanized_name
    _('Build Timeout')
  end
end

